require 'glimmer-dsl-libui'
require 'json'

require_relative './GUI.rb'
require_relative './Game_window.rb'
require_relative './Settings_window.rb'
require_relative '../Network/Server_connection.rb'

class Main_window < GUI
    include Glimmer

    attr_accessor :code, :nickname

    def initialize
        super
        if @size == nil
            if @config[:GUI]["#{self.class.name}"] == nil
                @size = @config[:GUI][:standard_size]
            end
        end
        @windows = {}
        @windows[:game_window] = Game_window.new
        @windows[:settings_window] = Settings_window.new
        @windows.each do |key, element|
            element.main
        end
    end

    def define_window x_size = 400, y_size = 400
        @window = window(@config[:application_name], x_size, y_size) {
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
                            msg_box 'Incorrect code', 'Please make sure you entered a valid code!'
                        else
                            @client.send_message 'room', 'join', {:code => code, :name => nickname}
                        end
                    end
                }
                button('Settings') {
                    stretchy false

                    on_clicked do
                        @windows[:settings_window].show_window
                    end
                }
            }
        }
    end
end
