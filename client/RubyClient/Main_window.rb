require 'glimmer-dsl-libui'
require 'json'

require 'GUI.rb'
require '../Server_connection.rb'

class Main_window < GUI
    include Glimmer

    attr_accessor :code, :nickname

    def initialize config = (JSON.load_file './config.json', {symbolize_names: true}), os = 'windows'
        @config = config
        @client = nil
        @os = os
        @server_thread = nil
    end

    def main
        showing_window define_main_window
    end

    def showing_window window = nil
        window.show
    end

    def define_loading_window x_size = 400, y_size = 400
        window = window(@config[:name])
        window
    end

    def define_main_window x_size = 400, y_size = 400
        window = window(@config[:name], x_size, y_size) {
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

    def define_game_window x_size = 400, y_size = 400
        window = window("#{@config[:name]}: Chess game", x_size, y_size) {

        }
        window
    end

    def define_settings_window x_size = 400, y_size = 400
        window = window("#{@config[:name]}: Settings", x_size, y_size) {

        }
        window
    end

    def start_connection
        @client = Server_connection.new @config[:server]
        @server_thread = Thread.new {
            @client.main
        }
    end
end
