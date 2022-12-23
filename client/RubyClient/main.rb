require 'eventmachine'
require 'faye/websocket'
require 'glimmer-dsl-libui'

BEGIN {
    prefix = "gem"
    begin
        unless system "#{prefix} list json"
            system "#{prefix} i json"
        end
    rescue => exception
        prefix = 'sudo gem'
        system "#{prefix} i json"
    end
    require 'json'
    (JSON.load File.open "./config.json")['gems']['priority'].each do |gem|
        unless system "#{prefix} list #{gem}"
            system "#{prefix} i #{gem}"
        end
        system "#{prefix} update #{gem}"
    end
    (JSON.load File.open "./config.json")['gems']['not_priority'].each do |gem|
        unless system "#{prefix} list #{gem}"
            system "#{prefix} i #{gem}"
        end
        system "#{prefix} update #{gem}"
    end
}

config = JSON.load File.open "./config.json"

server_thread = Thread.new {
    EM.run {
        socket = Faye::WebSocket::Client.new "ws://#{config['hostname']}:#{config['port']}/"
        socket.on :open do |event|
            p [:open]
        end
        socket.on :message do |event|
            p [:message, event.data]
        end
        socket.on :close do |event|
            p [:close, event.code, event.reason]
            socket = nil
        end
    }
}
server_thread.join
