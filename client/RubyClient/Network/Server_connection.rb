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
        connecting_to_server
    end

    def connecting_to_server
        @eventmachine = EM.run do
            @socket = Faye::WebSocket::Client.new "ws://#{@hostname}:#{@port}/"
            @socket.on :open do |event|
                p [:open]
            end
            @socket.on :message do |event|
                p [:message, event.data]
                puts message
            end
            @socket.on :close do |event|
                p [:close, event.code, event.reason]
                @socket = nil
            end
        end
    end

    def send_message type = nil, subtype = nil, content = nil
        message = {:type => type, :subtype => subtype, :content => content}
        @eventmachine.defer @socket.send(JSON.dump(message).to_s) #TODO: Errorhandling
    end
end
