require 'glimmer-dsl-libui'
require 'json'

require_relative './GUI.rb'

class Game_window < GUI
    include Glimmer

    def initialize
        super
        if @size == nil
            if @config[:GUI]["#{self.class.name}"] == nil
                @size = @config[:GUI][:standard_size]
            end
        end
        @nickname = nil
    end

    def define_window x_size = 400, y_size = 400
        @window = window("#{@config[:application_name]}: Playing as #{@nickname}...", x_size, y_size) {
            margined true
        }
    end
end
