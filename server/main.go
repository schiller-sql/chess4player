package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"server/domain"
	"server/websocket"
)

func handleWs(pool *websocket.Pool, w http.ResponseWriter, r *http.Request) {
	conn, err := websocket.Upgrade(w, r)
	if err != nil {
		log.Println("ERROR ", err)
	}
	log.Println("INFO socket endpoint hit from " + conn.RemoteAddr().String())
	client := &domain.Client{
		Conn:    conn,
		Handler: pool,
	}
	pool.Register <- client
	client.Read()
}

/*
TODO: different log levels
lowest to highest:
trace(Something very low level),
debug(Useful debugging information),
info(Something noteworthy happened),
warn(You should probably take a look at this),
error(Something failed but I'm not quitting),
fatal(Bye and exit),
panic(I'm bailing and calling panic())
*/
func main() {
	file, err := os.OpenFile("tmp/server.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		log.Printf("ERROR  %v\n", err)
		os.Exit(1)
	}
	defer func(f *os.File) {
		err := f.Close()
		if err != nil {
			log.Println("ERROR ", err)
		}
	}(file)
	wrt := io.MultiWriter(os.Stdout, file)
	log.SetOutput(wrt)
	pool := websocket.NewPool()
	go pool.Start()
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		handleWs(pool, w, r)
	})
	/*
		http.HandleFunc("/admin", func(w http.ResponseWriter, r *http.Request) {
			_, err := fmt.Fprintf(w, "Admin GUI here")
			if err != nil {
				log.Error(err)
			}
		})
	*/
	log.Println(
		"ERROR ", http.ListenAndServe(":8080", nil),
	)
	os.Exit(1)
}
