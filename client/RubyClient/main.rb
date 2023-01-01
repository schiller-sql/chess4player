require_relative './GUI/Loading_window.rb'
require_relative './GUI/Main_window.rb'

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

$os = nil
if OS.windows?
    $os = 'windows'
elsif OS.posix?
    $os = 'linux'
elsif OS.mac?
    $os = 'macos'
end

$config = JSON.load_file 'config.json', {symbolize_names: true}

$gui = {}
$gui[:loading_window] = Loading_window.new
$gui[:main_window] = Main_window.new

#gui_thread = Thread.new {$gui[:loading_window].main}

$gui[:loading_window].main

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
        $gui[:loading_window].update_status 'checking'
    end
    $config[:gems].each do |list|
        list.each do |gem_name|
            system "#{prefix} update #{gem_name}"
            $gui[:loading_window].update_status 'updating'
        end
    end
    $gui[:main_window].start_connection
}

gem_thread.join
#gui_thread.join
