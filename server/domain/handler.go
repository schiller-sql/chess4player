package domain

type Handler interface {
	Unregister(this *Client)
	Input(ClientEvent)
}
