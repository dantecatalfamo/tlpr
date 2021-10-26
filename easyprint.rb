#!/usr/bin/env ruby
# frozen_string_literal: true

require 'socket'
require 'optparse'
require 'yaml'

CUT_CMD = "\n\n\n\n\u001DV\u0001"
CONF_FILE = File.expand_path("~/.config/easyprint/easyprint.yaml")

Options = Struct.new(:no_cut, :ip)
options = Options.new

OptionParser.new do |opts|
  opts.banner = <<~END
  Usage: #{$PROGRAM_NAME} [options] [args...]
  Print either args or stdin through thermal printer.
  END

  opts.on("-n", "Don't cut after printing") do
    options.no_cut = true
  end

  opts.on("-iIP", "--ip=IP", "Printer IP address") do |ip|
    options.ip = ip
  end
end.parse!

if File.exists?(CONF_FILE)
  conf = YAML.load_file(CONF_FILE)
  options.ip = conf["IP"]
end

socket = TCPSocket.new(options.ip, 9100)

if ARGV.empty?
  STDIN.each_line do |line|
    socket.write(line)
  end
else
  socket.write(ARGV.join(' ') + "\n")
end

unless options.no_cut
  socket.write(CUT_CMD)
end
