#!/usr/bin/env ruby

def process(mp3)
  name = File.basename(mp3)
  raise 'weird' unless name
  root = name[1]
  
  webmName = "#{root}.webm"
  command = "ffmpeg -y -i #{mp3} #{webmName}"
  puts "#{mp3} -> #{webmName}"
  puts " * From: #{File.size(mp3)}"
  `#{command} 2>&1`
  puts " * To  : #{File.size(webmName)}"
end

mp3s = Dir.glob('*.mp?')

mp3s.each { |mp3| process(mp3) }
