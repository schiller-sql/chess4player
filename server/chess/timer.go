package chess

import (
	"time"
)

type Timer struct {
	Game      *Game
	Timer     *time.Timer
	isStopped chan bool
	Time      int64
}

func (this *Timer) Start() {
	startTime := time.Now()
	for {
		select {
		case <-this.Timer.C: //time is up
			this.Time = 0
			this.Game.Resign()
			return
		case <-this.isStopped: //timer is stopped by game
			this.Time -= int64(time.Since(startTime) /*nanoseconds*/ / time.Millisecond)
			return
		}
	}
}

func (this *Timer) Stop() {
	this.Timer.Stop()
	this.isStopped <- true
}

func NewTimer(pTime int64, game *Game) *Timer {
	return &Timer{
		Game:      game,
		Timer:     time.NewTimer(time.Duration(pTime) * time.Millisecond),
		Time:      pTime,
		isStopped: make(chan bool),
	}
}
