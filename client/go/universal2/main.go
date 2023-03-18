package main

import (
	"bufio"
	"fmt"
	"github.com/TylerBrock/colorjson"
	"github.com/fatih/color"
	"github.com/gorilla/websocket"
	"net/url"
	"os"
	"strconv"
	"strings"
)

func main() {
	var host string
	if len(os.Args) > 1 {
		host = os.Args[1]
	} else {
		host = "localhost:8080"
	}
	uri := url.URL{Scheme: "ws", Host: host, Path: "/"}
	conn, _, err := websocket.DefaultDialer.Dial(uri.String(), nil)
	if err != nil {
		printError(err)
	}
	go readMessagesFromTerminal(conn)

	printMessagesToTerminal(conn)
	for {

	}
}

func readMessagesFromTerminal(conn *websocket.Conn) {
	for {
		fmt.Print(color.GreenString(" > "))
		consoleReader := bufio.NewReader(os.Stdin)
		input, _ := consoleReader.ReadString('\n')
		if strings.HasPrefix(input, "exit") {
			conn.Close()
			printInfo("exiting")
			os.Exit(0)
		}
		switch {
		case strings.Contains(input, "create"):
			name := input[7 : len(input)-1]
			send(conn, "room", "create", map[string]interface{}{"name": name})
			break
		case strings.Contains(input, "join"):
			code := input[5:11]
			name := ""
			if len(input) > 12 {
				name = input[12 : len(input)-1]
			}
			send(conn, "room", "join", map[string]interface{}{"code": code, "name": name})
			break
		case strings.Contains(input, "leave"):
			send(conn, "room", "leave", map[string]interface{}{})
			break
		case strings.Contains(input, "start"):
			time, _ := strconv.Atoi(input[6 : len(input)-1])
			send(conn, "game", "start", map[string]interface{}{"time": time})
			break
		case strings.Contains(input, "move"):
			x1, _ := strconv.Atoi(input[5:6])
			y1, _ := strconv.Atoi(input[7:8])
			x2, _ := strconv.Atoi(input[9:10])
			y2, _ := strconv.Atoi(input[11:12])
			var promotion = ""
			if len(input) == 14 {
				promotion = string(input[13])
			}
			send(conn, "game", "move", map[string]interface{}{"move": []int{x1, y1, x2, y2}, "promotion": promotion})
			break
		case strings.Contains(input, "resign"):
			break
		case strings.Contains(input, "draw request"):
			send(conn, "game", "draw-request", map[string]interface{}{})
			break
		case strings.Contains(input, "draw accept"):
			send(conn, "game", "draw-accept", map[string]interface{}{})
			break
		default:
			printError(fmt.Errorf("could not find command"))
			break
		}
	}
}

func send(conn *websocket.Conn, commandType, commandSubType string, data any) {
	json := make(map[string]any)
	json["type"] = commandType
	json["subtype"] = commandSubType
	json["content"] = data
	printJson(true, json)
	err := conn.WriteJSON(conn)
	if err != nil {
		printError(err)
	}
}

func printMessagesToTerminal(conn *websocket.Conn) {
	for {
		//var jsonData map[string]any
		m, _, _ := conn.ReadMessage()
		print(string(m))
		//err := conn.(&jsonData)
		//if err != nil {
		//	printError(err)
		//} else {
		//	printJson(false, jsonData)
		//}
	}
}

var (
	errorColor    = color.New(color.BgRed, color.Underline, color.Italic)
	infoColor     = color.New(color.BgYellow, color.Underline, color.Italic)
	sentColor     = color.New(color.BgGreen, color.Underline, color.Bold)
	receivedColor = color.New(color.BgHiMagenta, color.Underline, color.Bold)
)

func printError(err error) {
	_, _ = errorColor.Println(fmt.Errorf("error: %e", err))
	fmt.Println()
}

func printInfo(info string) {
	_, _ = infoColor.Println(info)
	fmt.Println()
}

func printJson(sent bool, data map[string]any) {
	if sent {
		_, _ = sentColor.Println("sent:")
	} else {
		_, _ = receivedColor.Println("received:")
	}
	rawColored, _ := colorjson.Marshal(data)
	fmt.Println(string(rawColored))
	fmt.Println()
}
