package chess

import "time"

type Timer struct {
	isStopped chan bool
	Time      int64
	Game      *Game
	startTime chan int64
}

func NewTimer(time int64, game *Game) *Timer {
	return &Timer{
		isStopped: make(chan bool),
		startTime: make(chan int64),
		Time:      time,
		Game:      game,
	}
}

func (this *Timer) Start() {
	for {
		select {
		case currentTime := <-this.startTime:
			for range time.Tick(1 * time.Millisecond) {
				if currentTime > 0 {
					currentTime--
				} else {
					this.Game.Resign()
					return
				}
			}
		case <-this.isStopped:
			close(this.startTime)
			return
		}
	}
}
