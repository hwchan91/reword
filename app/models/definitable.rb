module Definitable
  extend ActiveSupport::Concern

  def define
    cached_definition = Rails.cache.read("define_#{@word}")
    return cached_definition if cached_definition

    result = wordnik_definition
    # result = words_api_definition if result.nil?
    # result = oxford_definition if result.nil?
    result
  end
  
  private
  def wordnik_definition
    response = Wordnik.word.get_definitions(word)
    definitions = response.map{|definition| definition['text']}
    definitions_in_string = definitions_to_string(definitions.reject{|definition| definition.length > 50})
    cache_and_return(word, definitions_in_string, 1.day)
  end

  def words_api_definition
    results = get_words_api_definition

    word_bases = results.map{|resp| {form: resp['partOfSpeech']} }
    pref_base = preferred_word_base(word_bases)

    definitions = extract_words_api_definitions(results, pref_base)
    definitions_in_string = definitions_to_string(definitions)
    cache_and_return(word, definitions_in_string, 1.day)
  rescue
    return nil
  end

  def oxford_definition
    lexical_entries = get_oxford_lexical_entries
    word_bases = lexical_entries.map{ |entry| {
      word: entry["inflectionOf"][0]["text"], 
      form: entry["lexicalCategory"]} 
    }
    pref_base = preferred_word_base(word_bases)

    lex_entries = get_oxford_definition(pref_base)
    definitions = extract_oxford_definitions(lex_entries, pref_base)
    definitions_in_string = definitions_to_string(definitions)

    cache_and_return(word, definitions_in_string, 1.hour)
  rescue
    return nil
  end

  def get_words_api_definition
    url = "https://wordsapiv1.p.mashape.com/words/#{word}"
    response = HTTParty.get(url,
                            headers: {
                                        "X-Mashape-Key" => ENV['MASHAPE_KEY'],
                                        "Accept" => "application/json"
                                    })
    response['results']
  end
  
  def get_oxford_lexical_entries
    inflection_url = "https://od-api.oxforddictionaries.com:443/api/v1/inflections/en/#{word}"
    inflection_response = HTTParty.get(inflection_url,
                                        headers: {
                                                  "Accept": "application/json",          
                                                  'app_id': ENV['OXFORD_ID'],
                                                  'app_key': ENV["OXFORD_KEY"] 
                                                  })

    inflection_response['results'][0]["lexicalEntries"]
  end

  def get_oxford_definition(word_base)
    definition_url = "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/#{word_base[:word]}"
    response =  HTTParty.get(definition_url,
                            headers: {
                                      "Accept": "application/json",          
                                      'app_id': ENV['OXFORD_ID'],
                                      'app_key': ENV["OXFORD_KEY"] 
                                      })

    response['results'][0]['lexicalEntries']
   end

  #get noun form first if noun form is a possible base, otherwise get verb, else get anything that comes first
  def preferred_word_base(word_bases)
    return {word: 'eat', form: "verb"} if word == 'ate' #make exception for this

    ["adjective", "adverb", "noun", "verb"].each do |form|
      base = word_bases.find{|word| word[:form].downcase == form }
      return base if base
    end
    word_bases[0]
  end

  def extract_words_api_definitions(results, pref_base)
    entries = results.select{|entry| entry['partOfSpeech'] == pref_base[:form]}.reject{|entry| entry['instanceOf'] }
    entries.map{|entry| entry['definition'].split(".")[0]} #cut short a very long paragraph
  end

  def extract_oxford_definitions(lex_entries, pref_base)
    # occassionally, the lemma will return a form that does not exist in the entries
    begin
      entries = lex_entries.find{|entry| entry['lexicalCategory'] == pref_base[:form]}['entries']
    rescue
      entries = lex_entries[0]['entries']
    end
    definitions = entries.map{|entry| entry['senses'].map{|s| (s['definitions']) ? s['definitions'][0]: (s['crossReferenceMarkers'] ? s['crossReferenceMarkers'][0] : nil) }}.compact
    definitions.map!{|entry| entry[0]}.reject!{|entry| entry.blank?}
    definitions
  end

  def definitions_to_string(definitions)
    if definitions.length > 1
      definitions = definitions[0..3].each_with_index.map do |defin, index| 
        "#{index + 1}. #{defin}"
      end
    end
    definitions.join("\t")
  end

  def cache_and_return(word, definitions_in_string, expiry)
    Rails.cache.write("define_#{word}", definitions_in_string, expires_in: expiry)
    return definitions_in_string
  end
end
