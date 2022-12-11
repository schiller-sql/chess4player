package websocket

type Handler interface {
	Unregister(this *Client)
	Input(ClientEvent)
}
