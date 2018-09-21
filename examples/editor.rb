#!/usr/bin/env ruby
#
# Web-based editor for ingredient lists, with real-time validation.
#
# 1. Install dependencies: gem install treetop sinatra
# 2. Run this: ruby editor.rb
# 3. Open your browser at: http://localhost:4567/
# 4. Type an ingredient list in the textbox.
#
# You'll see that the ingredients list is colorized.
#
require 'json'
require 'sinatra'
require_relative '../lib/food_ingredient_parser'

parser_strict = FoodIngredientParser::Strict::Parser.new
parser_loose  = FoodIngredientParser::Loose::Parser.new

get '/' do
  send_file 'editor.html'
end

get '/editor.css' do
  send_file 'editor.css'
end

post '/strict/render' do
  input = params[:text]
  parsed = parser_strict.parse(input)
  if parsed
    error = nil
    result = parsed.to_html
  elsif input.strip != ''
    # If parsing failed, add error and try partial parsing to return the part that can be parsed.
    # This is currently an undocumented way to retrieve the error location, so take care.
    error = {
      reason: parser_strict.parser.failure_reason,
      index: parser_strict.parser.failure_index,
      line: parser_strict.parser.failure_line,
      column: parser_strict.parser.failure_column
    }
    # Please note that consume_all_input may not remain present in all future releases.
    parsed = parser_strict.parse(input, consume_all_input: false)
    result = parsed&.to_html || ''
    result += input[parsed.interval.last .. (error[:index]-1)]
    result += "<span class='error'>#{input[error[:index]] || ' '}</span>"
  end

  headers("Content-Type" => "application/json; charset=utf-8")
  body({
    html: result,
    error: error
  }.to_json)
end

post '/loose/render' do
  input = params[:text]
  parsed = parser_loose.parse(input)

  headers("Content-Type" => "application/json; charset=utf-8")
  body({
    html: parsed&.to_html
  }.to_json)
end

post '/strict/parse' do
  parsed = parser_strict.parse(params[:text])
  headers("Content-Type" => "application/json; charset=utf-8")
  body(parsed&.to_h.to_json)
end

post '/loose/parse' do
  parsed = parser_loose.parse(params[:text])
  headers("Content-Type" => "application/json; charset=utf-8")
  body(parsed&.to_h.to_json)
end
