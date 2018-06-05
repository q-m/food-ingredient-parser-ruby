#!/usr/bin/env ruby
#
# Parser for food ingredient lists.
#
require 'pry'
require_relative 'ingredients-parser'

parser = IngredientsParser.new

def parse_show(s, parsed, inspect: false)
  puts "\e[1;32mEXAMPLE: \e[0;32m\"#{s}\"\e[0;22m"

  if parsed
    puts(parsed.inspect) if inspect
    Pry::ColorPrinter.pp(parsed.to_a)
  else
    puts "(no result)"
  end
end

def test_samples(parser, inspect: false)
  good = bad = 0
  File.foreach('data/ingredient-samples-nl-excerpt').with_index do |line, linenum|
    line = line.gsub('\\n', "\n").strip
    parsed = parser.parse(line.strip)
    good += 1 if parsed
    bad += 1 unless parsed

    parse_show(line, parsed, inspect: inspect) unless parsed
  end
  puts "good \e[1;32m#{good}\e[0;22m, bad \e[1;31m#{bad}\e[0;22m"
end

def test_tests(parser, inspect: false)
  examples = {
        "" => [],
        "tomaat" => [{name: "tomaat"}],
        "ingredienten: tomaat" => [{name: "tomaat"}],
        "tomaat; komkommer" => [{name: "tomaat"}, {name: "komkommer"}],
        "tomaat, komkommer" => [{name: "tomaat"}, {name: "komkommer"}],
        "tomaat. komkommer." => [{name: "tomaat"}, {name: "komkommer"}],
        "tomaat, komkommer: groen" => [{name: "tomaat"}, {name: "komkommer", contains: [{name: "groen"}]}],
        "rode tomaat, groene komkommer" => [{name: "rode tomaat"}, {name: "groene komkommer"}],
        "saus (tomaat, zout)" => [{name: "saus", contains: [{name: "tomaat"}, {name: "zout"}]}],
        "saus [tomaat, zout]" => [{name: "saus", contains: [{name: "tomaat"}, {name: "zout"}]}],
        "saus (tomaat, zout), water" => [{name: "saus", contains: [{name: "tomaat"}, {name: "zout"}]}, {name: "water"}],
        "p (a, b), q(c)" => [{name: "p", contains: [{name: "a"}, {name: "b"}]}, {name: "q", contains: [{name: "c"}]}],
        "p (a, b (r)), q(c)" => [{name: "p", contains: [{name: "a"}, {name: "b", contains: [{name: "r"}]}]}, {name: "q", contains: [{name: "c"}]}],
        "p: a, b. q: c" => [{name: "p", contains: [{name: "a"}, {name: "b"}]}, {name: "q", contains: [{name: "c"}]}],
        "p: a, b. q: c." => [{name: "p", contains: [{name: "a"}, {name: "b"}]}, {name: "q", contains: [{name: "c"}]}],
        "o, p: a/b, q: c" => [{name: "o"}, {name: "p", contains: [{name: "a"}, {name: "b"}]}, {name: "q", contains: [{name: "c"}]}],
        #"Met kip: vlees en dierlijke bijproducten (waarvan 4% kip), granen, mineralen. Met gevogelte: vlees en dierlijke bijproducten (waarvan 4% gevogelte), granen, mineralen." => nil,
        #"Cacaomassa, suiker, 16% mangovulling [suiker, glucosestroop, 1% mangopuree, volle melkpoeder (LACTOSE, MELKEIWIT), cacaoboter, invertsuikerstroop, limoensap, alcohol, natuurlijk aroma, emulgator (lecithine (SOJA)), verdikkingsmiddel ( johannesbroodpitmeel, guarpitmeel, xanthaangom), kleurstof (caroteen)], 16% chilismaakvulling [suiker, palmvet, raapolie, magere cacaopoeder, cacaomassa, magere melkpoeder (LACTOSE, MELKEIWIT), Lactose (LACTOSE, MELKEIWIT), volle melkpoeder (LACTOSE, MELKEIWIT), wei-eiwit (LACTOSE, MELKEIWIT), dextrose, natuurlijk aroma, emulgator (lecithine (SOJA)), antioxidant (E306)], cacaoboter, emulgator [lecithine (SOJA)]. " => nil,
        #"suiker, WEIPOEDER (MELK), emulgator: SOJALECITHINE, aroma, Cacaogehalte: 30% minimum, Kan sporen van pinda, noten bevatten" => nil,
        #"{RIBSTER MINI} (44% mechanisch gescheiden varkensvlees, {tarwe}gluten, ketjap (water, aroma ({soja}), kleurstof: E150d), {soja}-eiwit), {KIPKORN MINI} (28% mechanisch gescheiden kippenvlees, water, {tarwe}gluten, antioxidant: ascorbinezuur, Kan sporen van {ei} bevatten.)" => nil,
        #"30% pompelmoezen sap. water. zuurteregelaar: citroenzuur. natuurlijke aroma's." => nil,
        #"TARWEBLOEM. zout. 2% kruiden en specerijen (SELDERIJ. MOSTERD).  emulgator: E481/SOJALECITHINE. erwteneiwit. kleurstof: E150d.  E= door EU goedgekeurde hulpstoffen." => nil,
        #"Vulstof (cellulose)| droogextract van sint-janskruid (Hypericum perforatum) 14,7%| verdikkingsmiddel (natriumcarboxymethylcellulose)| glansmiddel (katoenzaadolie)." => nil,
        #"Zoetstof: Maltitolen. chocolade 15% (cacaomassa. zoetstof: maltitolen. cacaoboter. emulgator: SOJAlecithinen. natuurlijk vanille-aroma). water. TARWEbloem. verstevigingsmiddelen. TARWEzetmeel en maltodextrine. bevochtigingsmiddel: glycerol. EI. zuurteregelaars: citroenzuur en natriumcitraten. geleermiddel; pectines. sinaasappelconcentraat 0.7%. koolzaadolie. rijsmiddel: ammoniumcarbonaten. emulgatoren: mono- en diglyceriden en polyglycerolesters van vetzuren. natuurlijk sinaasappelaroma. zout. kleurstof: carotenen." => nil,

        ### Ingredient lists with issues
        # # pending amount parsing
        # "Volkorengranen (61%) (HAVER, GERST), rozijnen (10%), suiker, aroma's. Vitaminen en Mineralen: vitaminen (B3/PP, B6) en ijzer. Allergenen: zie ingrediënten, in vet gemarkeerd." => nil,
        # # pending amount parsing
        # "Teer 10 mg, nicotine 0,8 mg, koolmonoxide 9 mg" => nil,
        # # pending amount parsing
        # "TARWEBLOEM. zout. 1.8% kruiden en specerijen (SELDERIJ. MOSTERD).  emulgator: E481/SOJALECITHINE. erwteneiwit. kleurstof: E150d.  E= door EU goedgekeurde hulpstoffen." => nil,
        # # missing comma after nested ingredient
        #"{RIBSTER MINI} (44% mechanisch gescheiden varkensvlees, {tarwe}gluten, ketjap (water, aroma ({soja}), kleurstof: E150d) {soja}-eiwit), {KIPKORN MINI} (28% mechanisch gescheiden kippenvlees, water, {tarwe}gluten, antioxidant: ascorbinezuur, Kan sporen van {ei} bevatten.)" => nil,
        # # nested ingredients without a name (too many comma's, they belong to previous ingredient)
        # # also pending amount parsing ("0,1% alcohol")
        # "Cacaomassa, suiker, 16% mangovulling [suiker, glucosestroop, 1% mangopuree, volle melkpoeder, (LACTOSE, MELKEIWIT), cacaoboter, invertsuikerstroop, limoensap, 0,1% alcohol, natuurlijk aroma, emulgator, (lecithine (SOJA)), verdikkingsmiddel ( johannesbroodpitmeel, guarpitmeel, xanthaangom), kleurstof (caroteen)], 16% chilismaakvulling [suiker, palmvet, raapolie, magere cacaopoeder, cacaomassa, magere melkpoeder (LACTOSE, MELKEIWIT), Lactose (LACTOSE, MELKEIWIT), volle melkpoeder (LACTOSE, MELKEIWIT), wei-eiwit (LACTOSE, MELKEIWIT), dextrose, natuurlijk aroma, emulgator (lecithine (SOJA)), antioxidant, (E306)], cacaoboter, emulgator [lecithine (SOJA)]. " => nil,
        # # confusing colons, not sure if there is a correct interpretation that is parseable
        #"Ingredienten: Natuurlijk mineraalwater, sappen uit geconcentreerde sappen uit: 9% sinaasappel, 1% citroen, 1% ananas, 1% mandarijn; voedingszuur: citroenzuur, aroma, zoetstof: sucralose, stevioglycosiden; verrijkt met: vitamine: C, vitamine A." => nil,
  }

  examples.each do |example, expected|
    parsed = parser.parse(example)
    parse_show(example, parsed, inspect: false)
  end
end

test_samples(parser, inspect: false)
#test_tests(parser, inspect: false)
