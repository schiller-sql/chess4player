require 'eventmachine'
require 'faye/websocket'
require 'json'

class Server_connection
    def initialize
        @config = JSON.load_file 'config.json', {symbolize_names: true}
        @eventmachine = nil
        @hostname = @config[:network][:hostname]
        @port = @config[:network][:port]
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
                JSON.parse message
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
