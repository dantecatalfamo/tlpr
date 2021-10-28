#!/usr/bin/env ruby
# frozen_string_literal: true

require 'socket'
require 'optparse'
require 'yaml'

CUT_CMD = "\n\n\n\n\u001DV\u0001"
CONF_FILE = File.expand_path('~/.config/tlpr/tlpr.yaml')

Options = Struct.new(:cut, :ip, :file)
options = Options.new

if File.exist?(CONF_FILE)
  conf = YAML.load_file(CONF_FILE)
  options.ip = conf['IP']
  options.cut = conf['CUT']
end

OptionParser.new do |opts|
  opts.banner = <<~BANNER
    Usage: #{$PROGRAM_NAME} [options] [args...]

    Print either args or stdin, or file through thermal printer.
    The configuration file is located at #{CONF_FILE}
  BANNER

  opts.on('-c', '--[no-]cut', 'Cut after printing') do |cut|
    options.cut = cut
  end

  opts.on('-iIP', '--ip=IP', 'Printer IP address') do |ip|
    options.ip = ip
  end

  opts.on('-fFILE', '--file=FILE', 'Print the contents of FILE') do |file|
    options.file = file
  end

  opts.on('--example-config', 'Print an example configuration to stdout') do
    puts <<~CONFIG
      ---
      IP: 192.168.0.5
      CUT: true
    CONFIG
    exit
  end
end.parse!

abort 'No IP configured.' unless options.ip

socket = TCPSocket.new(options.ip, 9100)

if options.file
  socket.write(File.read(options.file))
elsif ARGV.empty?
  $stdin.each_line do |line|
    socket.write(line)
  end
else
  socket.write("#{ARGV.join(' ')}\n")
end

socket.write(CUT_CMD) if options.cut
