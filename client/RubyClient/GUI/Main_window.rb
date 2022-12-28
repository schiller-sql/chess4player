require 'glimmer-dsl-libui'
require 'json'

require './graphical_user_interface.rb'
require '../Network/Server_connection.rb'

class Main_window < GUI
    include Glimmer

    attr_accessor :code, :nickname

    def initialize
        super
        @client = nil
        @server_thread = nil
    end

    def define_window x_size = 400, y_size = 400
        window = window(@config[:application_name], x_size, y_size) {
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

    def start_connection
        @client = Server_connection.new @config[:network]
        @server_thread = Thread.new {
            @client.main
        }
    end
end
