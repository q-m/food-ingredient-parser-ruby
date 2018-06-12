#!/usr/bin/env ruby
#
# Parser for food ingredient lists.
#
require 'optparse'
require_relative 'ingredients-parser'

begin
  require 'pry'
rescue loaderror
  # ok, we have a fallback
end

def pp(o)
  if defined?(Pry)
    Pry::ColorPrinter.pp(o)
  else
    puts(o.inspect)
  end
end

def parse_single(s, parsed=nil, parser: nil, verbosity: 1)
  puts "\e[0;32m\"#{s}\"\e[0;22m" if verbosity > 0
  parser ||= IngredientsParser.new
  parsed ||= parser.parse(s)

  if parsed
    puts(parsed.inspect) if verbosity > 1
    pp(parsed.to_a) if verbosity > 0
  else
    puts "(no result)" if verbosity > 0
  end
end

def parse_file(path, parser: nil, verbosity: 1)
  count_parsed = count_noresult = 0
  File.foreach(path) do |line|
    next if line =~ /^#/ # comment

    line = line.gsub('\\n', "\n").strip
    parsed = parser.parse(line)
    count_parsed += 1 if parsed
    count_noresult += 1 unless parsed

    parse_single(line, parsed, parser: parser, verbosity: verbosity)
  end

  puts "parsed \e[1;32m#{count_parsed}\e[0;22m, no result \e[1;31m#{count_noresult}\e[0;22m"
end

verbosity = 1
files = []
strings = []
OptionParser.new do |opts|
  opts.banner = <<-EOF.gsub(/^    /, '')
    Usage: #{$0} [options] --file|-f <filename>
           #{$0} [options] --string|-s <ingredients>

  EOF

  opts.on("-f", "--file FILE", "Parse all lines of the file as ingredient lists.") {|f| files << f }
  opts.on("-s", "--string INGREDIENTS", "Parse specified ingredient list.") {|s| strings << s }

  opts.on("-q", "--[no-]quiet", "Only show summary.") {|q| verbosity = q ? 0 : 1 }
  opts.on("-v", "--[no-]verbose", "Show more data (parsed tree).") {|v| verbosity = v ? 2 : 1 }
  opts.on("-h", "--help", "Show this help") do
    puts(opts)
    exit
  end
end.parse!

if strings.any? || files.any?
  parser = IngredientsParser.new
  strings.each {|s| parse_single(s, parser: parser, verbosity: verbosity) }
  files.each   {|f| parse_file(f, parser: parser, verbosity: verbosity) }
else
  STDERR.puts("Please specify one or more --file or --string arguments (see --help).")
end
