require 'glimmer-dsl-libui'
require 'json'

require './GUI.rb'

class Loading_window < GUI
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
        window = window(@config[:name], x_size, y_size)
        window
    end
end
