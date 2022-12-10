// api/index.js
var W3CWebSocket = require('websocket').w3cwebsocket;
var socket = new W3CWebSocket("ws://localhost:8080/ws");

let connect = () => {

    console.log("Attempting Connection...");

    socket.onopen = () => {
        console.log("Successfully Connected");
        sendMsg("joe mama")
    };

    socket.onmessage = msg => {
        console.log(msg);
    };

    socket.onclose = event => {
        console.log("Socket Closed Connection: ", event);
    };

    socket.onerror = error => {
        console.log("Socket Error: ", error);
    };
};

connect()

let sendMsg = msg => {
    console.log("sending msg: ", msg);
    socket.send(msg);
};


//export { connect, sendMsg };