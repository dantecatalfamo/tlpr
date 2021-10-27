#!/usr/bin/env ruby
# frozen_string_literal: true

require 'socket'
require 'optparse'
require 'yaml'

CUT_CMD = "\n\n\n\n\u001DV\u0001"
CONF_FILE = File.expand_path("~/.config/easyprint/easyprint.yaml")

Options = Struct.new(:cut, :ip)
options = Options.new

if File.exists?(CONF_FILE)
  conf = YAML.load_file(CONF_FILE)
  options.ip = conf["IP"]
  options.cut = conf["CUT"]
end

OptionParser.new do |opts|
  opts.banner = <<~END
  Usage: #{$PROGRAM_NAME} [options] [args...]
  Print either args or stdin through thermal printer.

  It has a config file is ~/.config/easyprint/easyprint.yaml in the following format:

  ---
  IP: 192.168.0.5
  CUT: true

  END

  opts.on("-c", "--[no-]cut", "Cut after printing") do |cut|
    options.cut = cut
  end

  opts.on("-iIP", "--ip=IP", "Printer IP address") do |ip|
    options.ip = ip
  end
end.parse!

socket = TCPSocket.new(options.ip, 9100)

if ARGV.empty?
  STDIN.each_line do |line|
    socket.write(line)
  end
else
  socket.write(ARGV.join(' ') + "\n")
end

if options.cut
  socket.write(CUT_CMD)
end
