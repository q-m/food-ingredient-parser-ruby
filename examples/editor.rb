#!/usr/bin/env ruby
#
# Web-based editor for ingredient lists, with real-time validation.
#
# 1. Install sinatra: gem install sinatra
# 2. Run this: ruby editor.rb
# 3. Open your browser at: http://localhost:4567/
# 4. Type an ingredient list in the textbox.
#
# You'll see that the ingredients list is colorized.
#
require 'json'
require 'sinatra'
require_relative '../lib/food_ingredient_parser'

parser = FoodIngredientParser::Parser.new

get '/' do 
  send_file 'editor.html'
end

get '/editor.css' do
  send_file 'editor.css'
end

post '/render' do
  # Don't consume all input, because it will help finding the error location.
  # Please note that this option may not remain present in future releases, so take care.
  parsed = parser.parse(params[:text], consume_all_input: false)
  # Even for an HTML fragment - https://stackoverflow.com/a/48277672/2866660
  headers "Content-Type" => "text/html; charset=utf-8"
  body parsed&.to_html
end

post '/parse' do
  parsed = parser.parse(params[:text])
  headers "Content-Type" => "application/json; charset=utf-8"
  body r&.to_h.to_json
end
