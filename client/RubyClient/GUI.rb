require 'glimmer-dsl-libui'
require 'json'

require './Client.rb'

class GUI
    include Glimmer

    attr_accessor :code

    def initialize
        @config = JSON.load File.open './config.json'
        @client = Client.new
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
        window = window(@config['name'], 800, 800) {
            margined true

            vertical_box {
                button('Create game') {
                    stretchy false

                    on_clicked do
                        
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
        window = window(@config['name'], 800, 800) {

        }
        window
    end

    def define_settings_window
        window = window('Settings', 400, 400) {

        }
        window
    end
end
