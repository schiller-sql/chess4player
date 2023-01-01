require 'glimmer-dsl-libui'
require 'json'

class GUI
    include Glimmer

    def initialize size = nil
        @config = JSON.load_file 'config.json', {symbolize_names: true}
        @size = size
        @window = nil
    end

    def main
        define_window
        show_window
    end

    def show_window window = @window
        window.show
    end

    def close_window window = @window
        window.destroy
    end

    def define_window x_size = @size[:x_size], y_size = @size[:y_size]
        @window = window(@config[:application_name], x_size, y_size) {

        }
    end
end
