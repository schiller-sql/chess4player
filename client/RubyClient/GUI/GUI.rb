require 'glimmer-dsl-libui'
require 'json'

class GUI
    include Glimmer

    def define_window x_size = 400, y_size = 400
        window = window(@config[:name], x_size, y_size) {

        }
        window
end
