require 'eventmachine'
require 'faye/websocket'
require 'json'

class Client
    def initialize
        @config = JSON.load File.open './config.json'
        @socket = Faye::WebSocket::Client.new "ws://#{@config['server']['hostname']}:#{@config['server']['port']}/"
    end

    def main
        connecting_to_server
    end

    def connecting_to_server
        puts "Socket on"
        EM.run {
            @socket.on :open do |event|
                p [:open]
            end
            @socket.on :message do |event|
                p [:message, event.data]
            end
            @socket.on :close do |event|
                p [:close, event.code, event.reason]
                @socket = nil
            end
        }
    end
end
