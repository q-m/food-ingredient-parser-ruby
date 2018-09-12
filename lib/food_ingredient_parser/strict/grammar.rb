require 'treetop'
require_relative 'nodes'

# @todo find a way to auto-generate Ruby from Treetop files when building gem,
#       see https://stackoverflow.com/q/37794587/2866660

Treetop.load File.dirname(__FILE__) + '/grammar/common'
Treetop.load File.dirname(__FILE__) + '/grammar/amount'
Treetop.load File.dirname(__FILE__) + '/grammar/ingredient_simple'
Treetop.load File.dirname(__FILE__) + '/grammar/ingredient_nested'
Treetop.load File.dirname(__FILE__) + '/grammar/ingredient_coloned'
Treetop.load File.dirname(__FILE__) + '/grammar/ingredient'
Treetop.load File.dirname(__FILE__) + '/grammar/list'
Treetop.load File.dirname(__FILE__) + '/grammar/list_coloned'
Treetop.load File.dirname(__FILE__) + '/grammar/list_newlined'
Treetop.load File.dirname(__FILE__) + '/grammar/root'
