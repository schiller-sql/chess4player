require 'glimmer-dsl-libui'
require 'json'

require './Server_connection.rb'

class GUI
    include Glimmer

    attr_accessor :code, :nickname

    def initialize
        @config = JSON.load_file './config.json', {symbolize_names: true}
        @client = Server_connection.new @config[:server]
        @server_thread = nil
    end

    def main
        @server_thread = Thread.new { @client.main }
        showing_window define_main_window
    end

    def showing_window window = nil
        window.show
    end

    def define_main_window
        window = window(@config[:name], 800, 800) {
            margined true

            vertical_box {
                form {
                    stretchy false

                    entry {
                        label 'Nickname'
                        text <=> [self, :nickname]
                    }
                }
                button('Create game') {
                    stretchy false

                    on_clicked do
                        @client.send_message 'room', 'create', {:name => nickname}
                    end
                }
                form {
                    stretchy false

                    entry {
                        label 'Code'
                        text <=> [self, :code]
                    }
                }
                button('Join game') {
                    stretchy false

                    on_clicked do
                        if code == nil or code.length <= 0
                            msg_box 'Incorrect code', 'Please make sure you entered a code!'
                        else
                            @client.send_message 'room', 'join', {:code => code, :name => nickname}
                        end
                    end
                }
                button('Settings') {
                    stretchy false

                    on_clicked do
                        
                    end
                }
            }

            on_closing do
                @server_thread.exit
            end
        }
        window
    end

    def define_game_window
        window = window(@config[:name], 800, 800) {

        }
        window
    end

    def define_settings_window
        window = window('Settings', 400, 400) {

        }
        window
    end
end
