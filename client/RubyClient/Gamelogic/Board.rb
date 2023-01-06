require 'json'

require_relative './Field'
Dir[File.join(__dir__, 'Pieces', '*.rb')].each do |file|
    require_relative file
end

class Board
    def initialize
        @board = []
        fill_board
        place_pieces
        @config = (JSON.load_file 'config.json', {symbolize_names: true})
        @size = @config[:chess_logic][:board_size]
    end

    def fill_board
        @size.times do |line_index|
            @size.times do |column_index|
                unless line_index < 3 or line_index > (@size - 3) or column_index < 3 or column_index > (@size - 3)
                    @board[line_index][column_index] = Field.new
                else
                    @board[line_index][column_index] = nil
                end
            end
        end
    end

    def place_pieces players = 4
        @size.times do |line_index|
            unless @board[line_index][0] == nil or players == 2 or players == 4
                @board[line_index][1].set_piece 'pawn', 1
                @board[line_index][-2].set_piece 'pawn', 3
                case line_index
                when 3 or (@size - 3)
                    @board[line_index][0].set_piece 'rook', 1
                    @board[line_index][-1].set_piece 'rook', 3
                when 3 or (@size - 3)
                    @board[line_index][0].set_piece 'knight', 1
                    @board[line_index][-1].set_piece 'knigth', 3
                when 5 or (@size - 5)
                    @board[line_index][0].set_piece 'bishop', 1
                    @board[line_index][-1].set_piece 'bishop', 3
                when 6
                    @board[line_index][0].set_piece 'queen', 1
                    @board[line_index][-1].set_piece 'king', 3
                when 6
                    @board[line_index][0].set_piece 'king', 1
                    @board[line_index][-1].set_piece 'queen', 3
                end
            end
        end
        second_number = 2
        if players == 2
            second_number = 1
        end
        @size.times do |column_index|
            unless @board[0][column_index] == nil
                @board[1][column_index].set_piece 'pawn', second_number
                @board[-2][column_index].set_piece 'pawn', 0
                case line_index
                when 3 or (@size - 3)
                    @board[0][column_index].set_piece 'rook', second_number
                    @board[-1][column_index].set_piece 'rook', 0
                when 3 or (@size - 3)
                    @board[0][column_index].set_piece 'knight', second_number
                    @board[-1][column_index].set_piece 'knigth', 0
                when 5 or (@size - 5)
                    @board[0][column_index].set_piece 'bishop', second_number
                    @board[-1][column_index].set_piece 'bishop', 0
                when 6
                    @board[0][column_index].set_piece 'queen', second_number
                    @board[-1][column_index].set_piece 'king', 0
                when 6
                    @board[0][column_index].set_piece 'king', second_number
                    @board[-1][column_index].set_piece 'queen', 0
                end
            end
        end
    end

    def place_pieces_with_line_up line_up = nil 
        line_up.each do |line|
            line.each_with_index do |field, column|
                piece = nil
                team = 0
                unless field == nil or field == '--'
                    field.each_char do |char|
                        case char.class.name
                        when ''
                            case char.to_s
                            when 'b'
                                piece = 'bishop'
                            when 'k'
                                piece = 'king'
                            when 'n'
                                piece = 'knight'
                            when 'p'
                                piece = 'pawn'
                            when 'q'
                                piece = 'queen'
                            when 'r'
                                piece = 'rook'
                            end
                        when ''
                            team = char.to_i
                        else
                            break
                        end
                    end
                    @board[line][column].set_piece piece, team
                end
            end
        end
    end
end
