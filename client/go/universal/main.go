package main

import (
	"bufio"
	"flag"
	"fmt"
	"github.com/gorilla/websocket"
	"log"
	"net/url"
	"os"
	"os/signal"
	"strconv"
	"strings"
)

var addr = flag.String("addr", "localhost:8080", "http service address")

var board = make([][]Piece, 8)

type Message struct {
	Type    string                 `json:"type:"`
	SubType string                 `json:"subtype"`
	Content map[string]interface{} `json:"content"`
}

type Piece int

const (
	Empty Piece = iota
	Pawn
	Rook
	Knight
	Bishop
	Queen
	King
)

func main() {
	flag.Parse()
	log.SetFlags(0)
	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)
	u := url.URL{Scheme: "ws", Host: *addr, Path: "/"}
	log.Printf("connecting to %s", u.String())
	conn, _, err := websocket.DefaultDialer.Dial(u.String(), nil)
	if err != nil {
		log.Fatal("dial:", err)
	}
	defer func(c *websocket.Conn) {
		err := c.Close()
		if err != nil {
			log.Println("close", err)
		}
	}(conn)
	inputEvent := make(chan string)
	socketEvent := make(chan Message)

	for i := 0; i < 8; i++ {
		if i == 0 || i == 7 {
			board[i] = []Piece{Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook}
		} else if i == 1 || i == 6 {
			board[i] = []Piece{Pawn, Pawn, Pawn, Pawn, Pawn, Pawn, Pawn, Pawn}
		} else {
			board[i] = []Piece{Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty}
		}
	}

	go func() {
		defer close(inputEvent)
		printMainMenu()
		for {
			consoleReader := bufio.NewReader(os.Stdin)
			fmt.Print(">")
			input, _ := consoleReader.ReadString('\n')
			if strings.HasPrefix(input, "exit") {
				err := conn.Close()
				if err != nil {
					log.Println("close:", err)
					return
				}
				os.Exit(0)
			}
			inputEvent <- input
		}
	}()

	go func() {
		for {
			var message Message
			err := conn.ReadJSON(&message)
			if err != nil {
				log.Println("read:", err)
				return
			}
			log.Printf("\nrecv: %s", message)
			socketEvent <- message
		}
	}()

	for {
		select {
		case <-interrupt:
			log.Println("interrupt")
			err := conn.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			if err != nil {
				log.Println("write close:", err)
				return
			}
			err = conn.Close()
			if err != nil {
				log.Println("close:", err)
				return
			}
			return
		case order := <-inputEvent:
			switch {
			case strings.Contains(order, "create"):
				name := order[7 : len(order)-1]
				write(conn, "room", "create", map[string]interface{}{"name": name})
				printGameMenu()
				break
			case strings.Contains(order, "join"):
				code := order[5:11]
				name := order[12 : len(order)-1]
				write(conn, "room", "join", map[string]interface{}{"code": code, "name": name})
				printGameMenu()
				break
			case strings.Contains(order, "leave"):
				write(conn, "room", "leave", map[string]interface{}{})
				printMainMenu()
				break
			case strings.Contains(order, "start"):
				time, _ := strconv.Atoi(order[6 : len(order)-1])
				write(conn, "game", "start", map[string]interface{}{"time": time})
				printInGameMenu()
				printBoard()
				break
			case strings.Contains(order, "move 1 2 3 4 b"):
				x1, _ := strconv.Atoi(order[5:6])
				y1, _ := strconv.Atoi(order[7:8])
				x2, _ := strconv.Atoi(order[9:10])
				y2, _ := strconv.Atoi(order[11:12])
				var promotion = ""
				if len(order) == 14 {
					promotion = string(order[13])
				}
				move(x1, y1, x2, y2, promotion)
				printBoard()
				break
			case strings.Contains(order, "resign"):
				break
			case strings.Contains(order, "draw-request"):
				break
			case strings.Contains(order, "draw-accept"):
				break
			}
			break
		case input := <-socketEvent:
			switch input.Type {
			case "room":
				switch input.SubType {
				case "participants-count-update":
					fmt.Println("participants-count-update: " + strconv.Itoa(int(input.Content["participants-count"].(float64))) + "\n>")
					break
				}
				break
			case "game":
				switch input.SubType {
				case "started":
					fmt.Println("started: player: " +
						((input.Content["participants"]).([]interface{})[0]).(string) + " time: " +
						strconv.Itoa(int(input.Content["time"].(float64))) + "\n>")
					break
				}
				break
			}
			break
		}
	}
}

func write(conn *websocket.Conn, messageType string, messageSubType string, messageContent map[string]interface{}) {
	err := conn.WriteJSON(Message{
		Type:    messageType,
		SubType: messageSubType,
		Content: messageContent,
	})
	if err != nil {
		log.Println(err)
		return
	}
}

func printMainMenu() {
	fmt.Println("\navailable commands: ")
	fmt.Println("1. create [optional <name>]")
	fmt.Println("2. join <code> [optional <name>]")
}

func printGameMenu() {
	fmt.Println("\navailable commands: ")
	fmt.Println("1. start <time>")
	fmt.Println("2. leave")
}

func printInGameMenu() {
	fmt.Println("\navailable commands: ")
	fmt.Println("1. move x1 y1 x2 y2 [optional <promotion>]")
	fmt.Println("2. resign")
	fmt.Println("3. draw-request")
	fmt.Println("4. draw-accept")
}

func printBoard() {
	for row := 0; row < 8; row++ {
		for column := 0; column < 8; column++ {
			fmt.Print(board[row][column], " ")
		}
		fmt.Print("\n")
	}
}

func move(x1 int, y1 int, x2 int, y2 int, promotion string) {

}
