package websocket

import (
	"fmt"
	"math/rand"
	"server/board"
	"server/domain"
	"sync"
	"time"
)

type Game struct {
	forceGameEnd chan bool
	leavesGame   chan *domain.Client
	message      chan domain.ClientEvent
	hasEnded     bool
	m            sync.Mutex
}

func (g *Game) ForceGameEnd() {
	g.forceGameEnd <- true
}

func (g *Game) LeavesRoom(client *domain.Client) {
	g.leavesGame <- client
}

func (g *Game) Event(event domain.ClientEvent) {
	g.message <- event
}

func (g *Game) HasEnded() bool {
	g.m.Lock()
	defer g.m.Unlock()
	return g.hasEnded
}

func StartGame(clients map[*domain.Client]string, time uint) *Game {
	g := Game{
		forceGameEnd: make(chan bool),
		leavesGame:   make(chan *domain.Client),
		message:      make(chan domain.ClientEvent),
	}
	// because clients may change
	clientsCopy := make(map[*domain.Client]string)
	for client, name := range clients {
		clientsCopy[client] = name
	}
	go g.game(clientsCopy, time)
	return &g
}

type gameState struct {
	board             *board.Board
	clients           map[*domain.Client]string
	playerOrder       [4]*player
	playerTime        [4]uint
	whoseTurn         int
	lastTurnTimestamp time.Time
	turnTimer         *time.Timer
	gameHasEnded      bool
}

type player struct {
	name         string
	client       *domain.Client
	acceptedDraw bool
}

func (g *Game) game(clients map[*domain.Client]string, timePerPlayer uint) {
	state := gameState{clients: clients}

	for i := 0; i < 4; i++ {
		state.playerTime[i] = timePerPlayer
	}

	var players []*player
	for client, name := range clients {
		players = append(players, &player{client: client, name: name})
	}
	rand.Seed(time.Now().UnixNano())
	rand.Shuffle(len(players), func(i, j int) { players[i], players[j] = players[j], players[i] })

	if len(players) == 2 {
		state.playerOrder[0] = players[0]
		state.playerOrder[2] = players[1]
	} else {
		copy(state.playerOrder[:], players) // TODO: suspekt
	}

	var generate [4]bool
	for i := 0; i < 4; i++ {
		if state.playerOrder[i] != nil {
			generate[i] = true
		}
	}
	b := &board.Board{}
	b.GenerateBoard(generate)
	state.board = b

	var participantsOrderSerialized [4]*string
	for i := 0; i < 4; i++ {
		if state.playerOrder[i] != nil {
			participantsOrderSerialized[i] = &state.playerOrder[i].name
		}
	}

	startEvent := map[string]interface{}{
		"time":         timePerPlayer,
		"participants": participantsOrderSerialized,
	}
	for client := range clients {
		client.Write("game", "started", startEvent)
	}
	state.firstTurn()
	for !state.gameHasEnded {
		select {
		case <-state.turnTimer.C:
			// timePerPlayer end for player whose turn it is
			{
				state.playerHasLost(state.whoseTurn, true)
			}
		case leftGame := <-g.leavesGame:
			{
				playerNumber := -1
				for i := 0; i < 4; i++ {
					if state.playerOrder[i] != nil && state.playerOrder[i].client == leftGame {
						playerNumber = i
					}
				}
				if playerNumber == -1 {
					break
				}
				delete(state.clients, leftGame)
				state.playerHasLost(playerNumber, false)
			}
		case message := <-g.message:
			playerNumber := -1
			for i := 0; i < 4; i++ {
				if state.playerOrder[i] != nil && state.playerOrder[i].client == message.Client {
					playerNumber = i
				}
			}
			if playerNumber == -1 {
				break
			}
			switch message.Message.SubType {
			case "move":
				{
					rawMoveData, ok := message.Message.Content["move"]
					if !ok {
						break
					}
					unCastedMoveData, _ := rawMoveData.([]interface{})
					var moveData [4]int
					for i, v := range unCastedMoveData {
						moveData[i] = int(v.(float64))
					}
					fmt.Printf("%#v", moveData)
					var promotion *string
					rawPromotion, promotionKeyFound := message.Message.Content["promotion"]
					castedRawPromotion, promotionCouldBeCast := rawPromotion.(string)
					if castedRawPromotion == "" || !promotionKeyFound || !promotionCouldBeCast {
						promotion = nil
					} else {
						promotion = &castedRawPromotion
					}
					m := move{Promotion: promotion, Move: moveData}
					playerDirection := board.Direction(playerNumber)
					from := board.Point{X: moveData[0], Y: moveData[1]}
					to := board.Point{X: moveData[2], Y: moveData[3]}
					var promotionPiece *board.Piece
					if promotion != nil {
						promotionPiece = &board.Piece{
							Type:      board.PieceTypeFromChar(*promotion),
							Direction: playerDirection,
						}
					}
					validMove := state.board.ValidMove(from, to, promotionPiece, playerDirection)
					if !validMove {
						// TODO
					}
					state.board.Move(from, to, promotionPiece)
					state.turnHasEnded(map[string]string{}, &m, false)
				}
			case "resign":
				{
					state.playerHasLost(playerNumber, false)
				}
			case "draw-request":
				state.drawAction(message.Client, true)
				break
			case "draw-accept":
				state.drawAction(message.Client, false)
				break
			}
		case <-g.forceGameEnd:
			state.gameHasEnded = true
		}
	}
	state.turnTimer.Stop()
	g.m.Lock()
	g.hasEnded = true
	g.m.Unlock()
}

func (s *gameState) drawAction(sender *domain.Client, wasRequest bool) {
	for _, p := range s.playerOrder {
		if p != nil && p.client == sender {
			p.acceptedDraw = true
		}
	}
	if s.allPlayersAcceptedDraw() {
		gameEndReason := "draw"
		s.sendGameUpdate(gameTurn{
			RemainingTime:    s.remainingTime(),
			LostParticipants: map[string]string{},
		}, &gameEndReason)
		s.gameHasEnded = true
	} else if wasRequest {
		m := map[string]interface{}{
			"requester": s.clients[sender],
		}
		s.sendToAllPlayers("draw-requested", m)
	}
}

func (s *gameState) allPlayersAcceptedDraw() bool {
	for _, p := range s.playerOrder {
		if p != nil && !p.acceptedDraw {
			return false
		}
	}
	return true
}

func (s *gameState) remainingTime() uint {
	// TODO: method is called multiple times, once to send to clients
	// TODO: and a second time to save in the gameState
	now := time.Now()
	passedTime := uint(now.Sub(s.lastTurnTimestamp).Milliseconds())
	return s.playerTime[s.whoseTurn] - passedTime
}

func (s *gameState) remainingPlayersCount() int {
	count := 0
	for i := 0; i < 4; i++ {
		if s.playerOrder[i] != nil {
			count++
		}
	}
	return count
}

type move struct {
	Move      [4]int  `json:"move"`
	Promotion *string `json:"promotion"`
}

type gameTurn struct {
	RemainingTime    uint              `json:"remaining-time"`
	Move             *move             `json:"move"`
	LostParticipants map[string]string `json:"lost-participants"`
}

func (s *gameState) firstTurn() {
	s.whoseTurn = 3
	s.lastTurnTimestamp = time.Now()
	s.nextTurn()
}

func (s *gameState) nextTurn() {
	s.playerTime[s.whoseTurn] = s.remainingTime()
	turn := s.whoseTurn + 1
	if turn == 4 {
		turn = 0
	}
	for s.playerOrder[turn] == nil {
		turn++
		if turn == 4 {
			turn = 0
		}
	}
	s.whoseTurn = turn
	playerTime := s.playerTime[turn]
	if s.turnTimer != nil {
		s.turnTimer.Stop()
	}
	s.turnTimer = time.NewTimer(time.Duration(playerTime) * time.Millisecond)
	s.lastTurnTimestamp = time.Now()
}

func (s *gameState) playerHasLost(player int, onTime bool) {
	s.board.PlayerDead(board.Direction(player))
	name := s.playerOrder[player].name
	s.playerOrder[player] = nil
	var playerDeathReason string
	if onTime {
		playerDeathReason = "time"
	} else {
		playerDeathReason = "resign"
	}
	lostParticipants := map[string]string{name: playerDeathReason}
	if s.remainingPlayersCount() == 1 {
		var remainingTime uint = 0
		if !onTime {
			remainingTime = s.remainingTime()
		}
		s.gameHasEnded = true
		var gameEnd string
		if onTime {
			gameEnd = "lost to time"
		} else {
			gameEnd = "resign"
		}
		s.sendGameUpdate(gameTurn{
			RemainingTime:    remainingTime,
			LostParticipants: lostParticipants,
		}, &gameEnd)
	} else if player != s.whoseTurn {
		s.sendResign(name)
	} else {
		s.turnHasEnded(lostParticipants, nil, onTime)
		// game continues
	}
}

func (s *gameState) turnHasEnded(lostParticipants map[string]string, move *move, remainingTimeIsZero bool) {
	var remainingTime uint
	if remainingTimeIsZero {
		remainingTime = 0
	} else {
		remainingTime = s.remainingTime()
	}
	for {
		s.nextTurn()
		checkmate, remi := s.board.CheckEndForDirection(board.Direction(s.whoseTurn))
		if checkmate || remi {
			s.board.PlayerDead(board.Direction(s.whoseTurn))
			lostName := s.playerOrder[s.whoseTurn].name
			var playerDeathReason string
			if checkmate {
				playerDeathReason = "checkmate"
			} else {
				playerDeathReason = "remi"
			}
			lostParticipants[lostName] = playerDeathReason
			s.playerOrder[s.whoseTurn] = nil
			if s.remainingPlayersCount() == 1 {
				s.gameHasEnded = true
				s.sendGameUpdate(gameTurn{
					RemainingTime:    remainingTime,
					LostParticipants: lostParticipants,
					Move:             move,
				}, &playerDeathReason)
				return
			}
		} else {
			break
		}
	}
	s.sendGameUpdate(gameTurn{
		RemainingTime:    remainingTime,
		Move:             move,
		LostParticipants: lostParticipants,
	}, nil)
}

func (s *gameState) sendResign(name string) {
	message := map[string]interface{}{
		"participant": name,
	}
	s.sendAllInRoom("player-resigned", message)
}

type gameUpdate struct {
	Turns   []gameTurn `json:"turns"`
	GameEnd *string    `json:"game-end"`
}

func (s *gameState) sendGameUpdate(turn gameTurn, gameEnd *string) {
	gameUpdate := gameUpdate{
		Turns:   []gameTurn{turn},
		GameEnd: gameEnd,
	}
	s.sendAllInRoom("game-update", gameUpdate)
}

func (s *gameState) sendAllInRoom(returnSubType string, message interface{}) {
	for client := range s.clients {
		client.Write("game", returnSubType, message)
	}
}

func (s *gameState) sendToAllPlayers(returnSubType string, message interface{}) {
	for _, p := range s.playerOrder {
		if p != nil {
			p.client.Write("game", returnSubType, message)
		}
	}
}
