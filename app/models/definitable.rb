module Definitable
  extend ActiveSupport::Concern

  OTHER_FORMS = ['adjective', 'adverb', 'pronoun', 'conjunction', 'preposition', 'interjection', 'article']

  def define
    cached_definition = Rails.cache.read("define_#{@word}")
    return cached_definition if cached_definition

    result = wordnik_definition
    # result = words_api_definition if result.nil?
    # result = oxford_definition if result.nil?

    result
    # translate(result)
  end

  def translate(result)
    response = HTTParty.post("https://translation.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE_TRANSLATE_KEY']}",
    body: {
      q: result,
      target: 'zh'
    })

    translation = response['data']['translations'].first['translatedText']
  end

  private
  def wordnik_definition
    search_word = word
    response = Wordnik.word.get_definitions(word, use_canonical: true)
    # with use_canonical, maybe not necessarily to try to convert plural/present tense anymore
    if (response.empty? and word[-1] == 's') or response.first['text'].downcase.include?('plural form')
      search_word = word[0..-2]
      response = Wordnik.word.get_definitions(search_word)
    end
    return nil if response.empty?

    chosen_definitions = chosen_def(response, search_word)
    definitions_in_string = definitions_to_string(chosen_definitions)
    cache_and_return(word, definitions_in_string, 1.day)
  rescue
    nil
  end

  def chosen_def(response, search_word)
    verb_response = response.select{|definition| definition['partOfSpeech'].include? 'verb' and !definition['partOfSpeech'].include? 'adverb' }
    noun_response = response.select{|definition| definition['partOfSpeech'].include? 'noun'  and !definition['partOfSpeech'].include? 'pronoun' }
    other_form_responses = OTHER_FORMS.map{|form| response.select{|definition| definition['partOfSpeech'].include? form } }
    all_forms = [verb_response] + [noun_response] + other_form_responses

    #chooses the 2 forms that have the most responses
    top_forms = all_forms.reject{|resp| resp.empty? }.sort_by{|resp| resp.length}.reverse[0..1]
    definitions_per_form = top_forms.map{ |form| form.map{|defin| defin['text']} }#.reject{|defin| defin.include?("  ") and !defin.include?(":  ") } }

    if definitions_per_form.length > 1
      chosen_definitions = filter_def(definitions_per_form.first, search_word, 3) + filter_def(definitions_per_form.last, search_word, 1)
    else
      chosen_definitions =  filter_def(definitions_per_form.first, search_word, 4)
    end
  end

  def filter_def(definitions, search_word, limit)
    output = []
    @used_words ||= []
    definitions.each do |defin|
      words = defin.downcase.scan(/\w+/).reject{|word| word.length < 4}
      next if words.select{|word| @used_words.include?(word)}.length >= 3
      @used_words += words.select{|word| word != search_word and !@used_words.include?(word) }
      output << defin
      break if output.length == limit
    end
    output
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
    definitions.each{|defin| defin.slice!(/\d/)} #remove subscripts
    if definitions.length >= 4
      definitions = (definitions[0..2] + [definitions[-1]]).each_with_index.map do |defin, index|
        "#{index + 1}. #{defin}"
      end
    elsif definitions.length > 1 and definitions.length < 4
      definitions = definitions.each_with_index.map do |defin, index|
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
