require './GUI/Loading_window.rb'

BEGIN {
    prefix = 'gem'
    begin
        begin
            Gem::Specification.find_by_name 'json'
        rescue => Gem::LoadError
            system "#{prefix} i json"
        end
    rescue => exeption
        prefix = 'sudo gem'
        system "#{prefix} i json"
    end
    require 'json'
    begin
        (JSON.load_file './config.json', {symbolize_names: true})[:gems][:priority].each do |gem|
            begin
                Gem::Specification.find_by_name gem
            rescue => Gem::LoadError
                system "#{prefix} i #{gem}"
            end
        end
    rescue => exeption
        prefix = 'sudo gem'
        system "#{prefix} i #{gem}"
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

gui = Loading_window.new $config, $os
gem_thread = Thread.new {
    prefix = 'gem'
    if $os == 'linux' or $os == 'macos'
        prefix = 'sudo gem'
    end
    $config[:gems][:non_priority].each do |gem|
        begin
            Gem::Specification.find_by_name gem
        rescue => Gem::LoadError
            system "#{prefix} i #{gem}"
        end
    end
    $config[:gems].each do |list|
        list.each do |gem|
            system "#{prefix} update #{gem}"
        end
    end
    gui.start_connection
}

gui.main
