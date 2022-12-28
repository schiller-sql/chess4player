require 'glimmer-dsl-libui'
require 'json'

class GUI
    include Glimmer

    def initialize config = (JSON.load_file '../config.json', {symbolize_names: true}), size = nil
        @config = config
        @size = size
        if @size == nil
            if @config[:GUI]["#{self.class.name}"] == nil
                @size = @config[:GUI][:standard_size]
            end
        end
    end

    def main
        showing_window define_window
    end

    def showing_window window = nil
        window.show
    end

    def define_window x_size = @size.fetch(:x_size), y_size = @size.fetch(:y_size)
        window = window(@config[:application_name], x_size, y_size) {

        }
        window
    end
end
