require_relative './GUI/Loading_window.rb'
require_relative './GUI/Main_window.rb'
require_relative './Network/Server_connection.rb'

BEGIN {
    prefix = 'gem'
    begin
        begin
            Gem::Specification.find_by_name 'json'
        rescue => Gem::MissingSpecError
            system "#{prefix} i json"
        end
    rescue => exeption
        prefix = 'sudo gem'
        system "#{prefix} i json"
    end
    require 'json'
    (JSON.load_file 'config.json', {symbolize_names: true})[:gems][:priority].each do |gem_name|
        unless gem_name == 'json'
            begin
                begin
                    Gem::Specification.find_by_name gem_name
                rescue => Gem::MissingSpecError
                    system "#{prefix} i #{gem_name}"
                end
            rescue => exeption
                prefix = 'sudo gem'
                system "#{prefix} i #{gem_name}"
            end
        end
    end
}

def checking_gems
    prefix = 'gem'
    if $os == 'linux' or $os == 'macos'
        prefix = 'sudo gem'
    end
    $config[:gems][:non_priority].each do |gem_name|
        begin
            Gem::Specification.find_by_name gem_name
        rescue => exception
            system "#{prefix} i #{gem_name}"
        end
        $gui[:loading_window].update_status 'checking'
    end
    $config[:gems].each do |list|
        list.each do |gem_name|
            system "#{prefix} update #{gem_name}"
            $gui[:loading_window].update_status 'updating'
        end
    end
end

$config = JSON.load_file 'config.json', {symbolize_names: true}
$gui = {}
$gui[:game_window] = Game_window.new
$gui[:loading_window] = Loading_window.new
$gui[:main_window] = Main_window.new
$gui.each do |key, element|
    element.main
end
$os = nil
if OS.windows?
    $os = 'windows'
elsif OS.posix?
    $os = 'linux'
elsif OS.mac?
    $os = 'macos'
end
$socket = Server_connection.new
$threads = {}

gem_process = spawn checking_gems
$gui[:loading_window].show_window
socket_process = spawn $socket.main
$gui[:main_window].show_window
