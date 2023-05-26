package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"server/domain"
	"server/websocket"
	"strconv"
)

func handleWs(pool *websocket.Pool, w http.ResponseWriter, r *http.Request) {
	conn, err := websocket.Upgrade(w, r)
	if err != nil {
		log.Println("FATAL ", err)
	}
	log.Println("DEBUG socket endpoint hit from " + conn.RemoteAddr().String())
	client := &domain.Client{
		Conn:    conn,
		Handler: pool,
	}
	pool.Register <- client
	client.Read()
}

func openLogFile() (*os.File, error) {
	err := os.MkdirAll("tmp", os.ModePerm)
	if err != nil {
		return nil, err
	}
	file, err := os.OpenFile("tmp/server.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		return nil, err
	}
	return file, nil
}

/*
TODO: different log levels
lowest to highest:
trace(Something very low level),
debug(Useful debugging information),
info(Something noteworthy happened),
warn(You should probably take a look at this),
error(Something failed, but I'm not quitting),
fatal(Bye and exit),
panic(I'm bailing and calling panic())
*/
func main() {
	port, a := os.LookupEnv("PORT")
	if !a {
		port = "8080"
	} else if portNum, err := strconv.Atoi(port); err != nil || portNum < 0 || portNum > 65535 {
		log.Println("FATAL ", "not a real port at env variable PORT")
		os.Exit(1)
	}

	log.Println("INFO starting server on port: " + port)
	file, err := openLogFile()
	if err != nil {
		log.Println("FATAL ", err)
		os.Exit(1)
	}
	defer func(f *os.File) {
		err := f.Close()
		if err != nil {
			log.Println("FATAL ", err)
			os.Exit(1)
		}
	}(file)
	wrt := io.MultiWriter(os.Stdout, file)
	log.SetOutput(wrt)
	log.Println("INFO starting pool")
	pool := websocket.NewPool()
	go pool.Start()
	log.Println("INFO handle routing")
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		handleWs(pool, w, r)
	})
	log.Println(
		"FATAL ", http.ListenAndServe(":"+port, nil),
	)
	log.Println("PANIC force shutdown server")
	os.Exit(1)
}
