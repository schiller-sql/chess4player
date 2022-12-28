require 'glimmer-dsl-libui'
require 'json'

require './graphical_user_interface.rb'

class Loading_window < GUI
    include Glimmer

    def initialize
        super
        @status = 0
    end

    def define_window x_size = 400, y_size = 400
        window = window("#{@config[:application_name]}: Loading...", x_size, y_size) {
            progress_bar
        }
        window
    end

    def update_status value = 0
        @status += value
    end
end
