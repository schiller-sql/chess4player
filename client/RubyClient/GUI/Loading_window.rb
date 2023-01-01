require 'glimmer-dsl-libui'
require 'json'

require_relative './GUI.rb'

class Loading_window < GUI
    include Glimmer

    def initialize
        super
        if @size == nil
            if @config[:GUI]["#{self.class.name}"] == nil
                @size = @config[:GUI][:standard_size]
            end
        end
        @status = [
            ['Checking gems', 100 / @config[:gems][:priority].length],
            ['Updating gems', 0]
        ]
        @window = define_window
    end

    def define_window x_size = 400, y_size = 400
        @window = window("#{@config[:application_name]}: Loading...", x_size, y_size) {
            margined true

            vertical_box {
                table {
                    stretchy false

                    text_column('Task')
                    progress_bar_column('Progress')

                    cell_rows @status
                }
            }
        }
    end

    def update_status task = nil
        gem_size = @config[:gems][:priority].length + @config[:gems][:non_priority].length
        if task.downcase == 'checking'
            @status[0][1] += 100 / gem_size.to_f
        elsif task.downcase == 'updating'
            @status[1][1] += 100 / gem_size.to_f
        end
    end
end
