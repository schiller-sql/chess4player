require 'eventmachine'
require 'faye/websocket'

class Server_connection
    def initialize connection
        @eventmachine = nil
        @hostname = connection.fetch(:hostname)
        @port = connection.fetch(:port)
        @socket = nil
    end

    def main
        @socket = Faye::WebSocket::Client.new "ws://#{@hostname}:#{@port}/"
        @socket.on :open do |event|
            p [:open]
        end
        Thread.new{listen()}.join
        @socket.on :close do |event|
            p [:close, event.code, event.reason]
        end
    end

    def listen
        @socket.on :message do |event|
            p [:message, event.data]
            puts message
        end
    end

    def send type = nil, subtype = nil, content = nil
        message = {:type => type, :subtype => subtype, :content => content}
        @socket.send(JSON.dump(message).to_s)
    end
end
