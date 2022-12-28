require './GUI/Game_window.rb'
require './GUI/Loading_window.rb'
require './GUI/Main_window.rb'
require './GUI/Settings_window.rb'

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
    (JSON.load_file './config.json', {symbolize_names: true})[:gems][:priority].each do |gem_name|
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
}

$os = nil
if OS.windows?
    $os = 'windows'
elsif OS.posix?
    $os = 'linux'
elsif OS.mac?
    $os = 'macos'
end

$config = JSON.load_file './config.json', {symbolize_names: true}

$gui = Loading_window.new
gem_thread = Thread.new {
    prefix = 'gem'
    if $os == 'linux' or $os == 'macos'
        prefix = 'sudo gem'
    end
    $config[:gems][:non_priority].each do |gem_name|
        begin
            Gem::Specification.find_by_name gem_name
        rescue => Gem::MissingSpecError
            system "#{prefix} i #{gem_name}"
        end
    end
    $config[:gems].each do |list|
        list.each do |gem_name|
            system "#{prefix} update #{gem_name}"
        end
    end
    #$gui.start_connection
}

$gui.main
