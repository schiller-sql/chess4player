require './GUI.rb'

BEGIN {
    prefix = "gem"
    begin
        unless system "#{prefix} list json"
            system "#{prefix} i json"
        end
    rescue => exception
        prefix = 'sudo gem'
        system "#{prefix} i json"
    end
    require 'json'
    (JSON.load File.open "./config.json")['gems']['priority'].each do |gem|
        unless system "#{prefix} list #{gem}"
            system "#{prefix} i #{gem}"
        end
        system "#{prefix} update #{gem}"
    end
    (JSON.load File.open "./config.json")['gems']['not_priority'].each do |gem|
        unless system "#{prefix} list #{gem}"
            system "#{prefix} i #{gem}"
        end
        system "#{prefix} update #{gem}"
    end
}

GUI.new.main
