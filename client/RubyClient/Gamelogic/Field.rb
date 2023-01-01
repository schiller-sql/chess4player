require 'json'

Dir[File.join(__dir__, 'Pieces', '*.rb')].each do |file|
    require_relative file
end

class Field
    def initialize piece = nil
        @config = (JSON.load_file '../config.json', {symbolize_names: true})
        @piece = set_piece piece
    end

    def set_piece piece = nil, team = 0
        case piece.downcase
        when 'bishop'
            @piece = Bishop.new team
        when 'king'
            @piece = King.new team
        when 'knight'
            @piece = Knigth.new team
        when 'pawn'
            @piece = Pawn.new team
        when 'queen'
            @piece = Queen.new team
        when 'Rook'
            @piece = Rook.new team
        else
            @piece = nil
        end
    end
end
