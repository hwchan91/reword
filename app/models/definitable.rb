module Definitable
  extend ActiveSupport::Concern

  OTHER_FORMS = ['adjective', 'adverb', 'pronoun', 'conjunction', 'preposition', 'interjection', 'article']

  def define
    Rails.cache.fetch("define_#{word}", expires_in: 1.day) {wordnik_definition}
  end

  # def translate(result)
  #   response = HTTParty.post("https://translation.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE_TRANSLATE_KEY']}",
  #   body: {
  #     q: result,
  #     target: 'zh'
  #   })

  #   translation = response['data']['translations'].first['translatedText']
  # end

  def wordnik_response(recursive = true)
    cache = Rails.cache.read("resp_#{word}")
    return cache if cache

    @search_word, @response = word, Wordnik.word.get_definitions(word)

    if recursive
      retry_response if third_person_tense? or plural_tense? or past_tense?
    end

    result = {search_word: @search_word, response: @response}
    cache_and_return("resp_#{word}", result)
  end

  def associated_words
    cache = Rails.cache.read("asso_#{word}")
    return cache if cache

    definitions = wordnik_response[:response].map{|definition| definition['text']}.join(" ")
    words_in_def = definitions.split(/\W+/)
    filtered_words = words_in_def.select{|w| w.length == word.length }.map(&:downcase).uniq.reject{|w| w == word or Word.to_reject?(w) }
    result = filtered_words.select{|w| dict.dict[w] and !Word.new(w).transition_words.empty? } #within common dict

    cache_and_return("asso_#{word}", result)
  end

  private
  def third_person_tense?
    if @response.empty? and word[-1] == 's'
      @search_word = word[0..-2] 
    elsif @response.any? and first_definition.include?('third-person')
      @search_word = first_definition_words.last
    end
  end

  def plural_tense?
    if @response.any? and (['plural', 'of'] - first_definition_words).empty?
      @search_word = first_definition_words.last
    end
  end

  def past_tense?
    if @response.any? and (['past', 'tense'] - first_definition_words).empty?
      @search_word = first_definition_words.last
    end
  end

  def first_definition
    @first_definition ||= @response.first['text'].downcase
  end

  def first_definition_words
    @first_definition_words ||= first_definition.split(/[^a-zA-Z]+/)
  end

  def retry_response
    @response = Word.new(@search_word).wordnik_response(false)[:response]
  end

  def wordnik_definition
    cache = Rails.cache.read("define_#{word}")
    return cache if cache

    response = wordnik_response
    search_word, response = response[:search_word], response[:response]

    chosen_definitions = chosen_def(response, search_word)
    result = definitions_to_string(chosen_definitions)

    cache_and_return("define_#{word}", result)
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
      chosen_definitions = filter_def(definitions_per_form.first, search_word, 4)
    end
  end

  #remove definitions that are too similar to each other
  def filter_def(definitions, search_word, limit)
    output = []
    @used_words ||= []
    definitions.each do |defin|
      defin = remove_superscripts(defin)
      words = defin.downcase.scan(/\w+/).reject{|word| word.length < 4}
      next if words.select{|word| @used_words.include?(word)}.length >= 3
      @used_words += words.select{|word| word != search_word and !@used_words.include?(word) }
      output << defin
      break if output.length == limit
    end
    output.uniq #it happens that, it is possible to have duplicate definitions in wordnik
  end

  def remove_superscripts(defin)
    defin.split(/\W+/).map{|word| word.match?(/\w+\d+$/) ? word.gsub(/\d+/, '') : word }.join(' ')
  end

  # def words_api_definition
  #   results = get_words_api_definition

  #   word_bases = results.map{|resp| {form: resp['partOfSpeech']} }
  #   pref_base = preferred_word_base(word_bases)

  #   definitions = extract_words_api_definitions(results, pref_base)
  #   definitions_in_string = definitions_to_string(definitions)
  #   cache_and_return(word, definitions_in_string, 1.day)
  # rescue
  #   return nil
  # end

  # def oxford_definition
  #   lexical_entries = get_oxford_lexical_entries
  #   word_bases = lexical_entries.map{ |entry| {
  #     word: entry["inflectionOf"][0]["text"],
  #     form: entry["lexicalCategory"]}
  #   }
  #   pref_base = preferred_word_base(word_bases)

  #   lex_entries = get_oxford_definition(pref_base)
  #   definitions = extract_oxford_definitions(lex_entries, pref_base)
  #   definitions_in_string = definitions_to_string(definitions)

  #   cache_and_return(word, definitions_in_string, 1.hour)
  # rescue
  #   return nil
  # end

  # def get_words_api_definition
  #   url = "https://wordsapiv1.p.mashape.com/words/#{word}"
  #   response = HTTParty.get(url,
  #                           headers: {
  #                                       "X-Mashape-Key" => ENV['MASHAPE_KEY'],
  #                                       "Accept" => "application/json"
  #                                   })
  #   response['results']
  # end

  # def get_oxford_lexical_entries
  #   inflection_url = "https://od-api.oxforddictionaries.com:443/api/v1/inflections/en/#{word}"
  #   inflection_response = HTTParty.get(inflection_url,
  #                                       headers: {
  #                                                 "Accept": "application/json",
  #                                                 'app_id': ENV['OXFORD_ID'],
  #                                                 'app_key': ENV["OXFORD_KEY"]
  #                                                 })

  #   inflection_response['results'][0]["lexicalEntries"]
  # end

  # def get_oxford_definition(word_base)
  #   definition_url = "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/#{word_base[:word]}"
  #   response =  HTTParty.get(definition_url,
  #                           headers: {
  #                                     "Accept": "application/json",
  #                                     'app_id': ENV['OXFORD_ID'],
  #                                     'app_key': ENV["OXFORD_KEY"]
  #                                     })

  #   response['results'][0]['lexicalEntries']
  #  end

  # #get noun form first if noun form is a possible base, otherwise get verb, else get anything that comes first
  # def preferred_word_base(word_bases)
  #   return {word: 'eat', form: "verb"} if word == 'ate' #make exception for this

  #   ["adjective", "adverb", "noun", "verb"].each do |form|
  #     base = word_bases.find{|word| word[:form].downcase == form }
  #     return base if base
  #   end
  #   word_bases[0]
  # end

  # def extract_words_api_definitions(results, pref_base)
  #   entries = results.select{|entry| entry['partOfSpeech'] == pref_base[:form]}.reject{|entry| entry['instanceOf'] }
  #   entries.map{|entry| entry['definition'].split(".")[0]} #cut short a very long paragraph
  # end

  # def extract_oxford_definitions(lex_entries, pref_base)
  #   # occassionally, the lemma will return a form that does not exist in the entries
  #   begin
  #     entries = lex_entries.find{|entry| entry['lexicalCategory'] == pref_base[:form]}['entries']
  #   rescue
  #     entries = lex_entries[0]['entries']
  #   end
  #   definitions = entries.map{|entry| entry['senses'].map{|s| (s['definitions']) ? s['definitions'][0]: (s['crossReferenceMarkers'] ? s['crossReferenceMarkers'][0] : nil) }}.compact
  #   definitions.map!{|entry| entry[0]}.reject!{|entry| entry.blank?}
  #   definitions
  # end

  def definitions_to_string(definitions)
    if definitions.length > 1
      definitions = definitions.each_with_index.map do |defin, index|
        "#{index + 1}. #{defin}"
      end
    end
    definitions.join("\t")
  end

  def cache_and_return(key, value, expiry = 1.day)
    Rails.cache.write(key, value, expires_in: expiry)
    return value
  end
end
