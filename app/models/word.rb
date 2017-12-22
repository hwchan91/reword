class Word
  require_relative "dict"
  attr_accessor :word, :dict, :path, :index_changed, :full_match_indexes, :partial_match_indexes

  def initialize(word, dict = nil, no_reorder = false, path = [], index_changed = nil)
    @word = word
    @dict = (dict.nil?) ? Dict.new('common') : dict #cannot set default dict = Dict.new, because WordTrek passess nil as dict instead of nothing
    @path = path
    @index_changed = index_changed
    @no_reorder = no_reorder
  end

  def transition_words_through_substitution
    output = []
    @word.length.times do |position|
      ('a'..'z').to_a.each do |substitute|
        test_word = @word.clone
        test_word[position] = substitute
        output << [test_word, position] if @dict.valid?(test_word)
      end
    end
    output.uniq.reject{|w| w[0] == @word}
  end

  def transition_words_through_reordering
    output = []
    permutations = @word.split("").permutation.to_a.map{|arr| arr.join()}
    permutations.each do |word|
      output << [word, nil] if @dict.valid?(word)
    end
    output.uniq.reject{|w| w[0] == @word}
  end

  def transition_words
    output = self.transition_words_through_substitution
    unless @no_reorder
      output += self.transition_words_through_reordering
    end
    output
  end

  def partial_match_count(word_to_compare)
    word_letters = @word.split("")
    unmatch_letters = word_to_compare.split("")
    word_letters.each do |letter|
      unmatch_letters.delete_at(unmatch_letters.index(letter) || unmatch_letters.length)
    end
    word_to_compare.length - unmatch_letters.length
  end

  def full_match_count(word_to_compare)
    count = 0
    word_to_compare.length.times do |i|
      count += 1 if @word[i] == word_to_compare[i]
    end
    count
  end

  def only_full_match?(word_to_compare)
    full_match_count(word_to_compare) == partial_match_count(word_to_compare)
  end

  #should reduce rating by length of path of compared word and self; full_match set as '+1'
  def match_count(word_to_compare)
    unless @no_reorder
      count = partial_match_count(word_to_compare.word) - word_to_compare.path.length - path.length
      count += 1 if only_full_match?(word_to_compare.word) and count != 0
      count
    else
      count = full_match_count(word_to_compare.word) - word_to_compare.path.length - path.length
    end
  end

  def best_match_count(words_to_compare)
    best = 0
    words_to_compare.each do |comparison|
      comparison_best = match_count(comparison)
      if comparison_best > best
        best = comparison_best
      end 
    end
    best
  end

  def transition_word_objects
    @transition_word_objects ||= generate_transition_word_objects
  end
  
  def generate_transition_word_objects
    output = []
    path = @path.clone.push(@word)
    transition_words.each do |word, index_changed|
      output << Word.new(word, @dict, @no_reorder, path, index_changed)
    end
    output
  end

  def transition_words_closer_to_target(words_to_compare)
    return @sorted_output if @sorted_output
    output = []
    original_best = best_match_count(words_to_compare)
    transition_word_objects.each do |transition_word|
      transition_word_best = transition_word.best_match_count(words_to_compare)
      output << [transition_word, transition_word_best] if transition_word_best > original_best - 1 # -1 for one step in the right direction
    end
    @sorted_output = output.sort_by{|word, best_count| best_count}.reverse.map{|word, best_count| word}
  end

  def getting_closer?(words_to_compare)
    transition_words_closer_to_target(words_to_compare).length > 0
  end

  def choices(history)
    hash = {}
    transition_words_not_used(history).each do |word, index|
      if hash[index] 
        hash[index] << word
      else
        hash[index] = [word]
      end
    end
    hash
  end

  def valid_transition?(new_word, history)
    transition_words_not_used(history).map{|word, index| word}.include?(new_word)
  end

  def transition_words_not_used(history)
    transition_words.select{|word, index| !history.include?(word)}
  end

  def oxford_definition
    cached_definition = Rails.cache.read("define_#{@word}")
    return cached_definition if cached_definition

    inflection_url = "https://od-api.oxforddictionaries.com:443/api/v1/inflections/en/#{word}"
    inflection_response = HTTParty.get(inflection_url,
                                        headers: {
                                                  "Accept": "application/json",          
                                                  'app_id': ENV['OXFORD_ID'],
                                                  'app_key': ENV["OXFORD_KEY"] 
                                                  })

    lexical_entries = inflection_response['results'][0]["lexicalEntries"]
    word_bases = lexical_entries.map{|entry| {
                                              word: entry["inflectionOf"][0]["text"], 
                                              form: entry["lexicalCategory"]} 
                                            }
    word_base = preferred_word_base(word_bases) || { word: @word, form: nil }
    definition_url = "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/#{word_base[:word]}"
    response =  HTTParty.get(definition_url,
                            headers: {
                                      "Accept": "application/json",          
                                      'app_id': ENV['OXFORD_ID'],
                                      'app_key': ENV["OXFORD_KEY"] 
                                      })

    lex_entries = response['results'][0]['lexicalEntries']
    # occassionally, the lemma will return a form that does not exist in the entries
    begin
      entries = lex_entries.find{|entry| entry['lexicalCategory'] == word_base[:form]}['entries']
    rescue
      entries = lex_entries[0]['entries']
    end
    definitions = entries.map{|entry| entry['senses'].map{|s| (s['definitions']) ? s['definitions'][0]: (s['crossReferenceMarkers'] ? s['crossReferenceMarkers'][0] : nil) }}.compact
    definitions.map!{|entry| entry[0]}.reject!{|entry| entry.blank?}

    if definitions.length > 1
      definitions = definitions[0..3].each_with_index.map do |defin, index| 
        "#{index + 1}. #{defin}"
      end
    end
    definitions_in_string = definitions.join("\t")
    Rails.cache.write("define_#{@word}", definitions_in_string, expires_in: 1.hour)
    return definitions_in_string
  rescue
    return nil
  end
  
  def define
    cached_definition = Rails.cache.read("define_#{@word}")
    return cached_definition if cached_definition
    url = "https://wordsapiv1.p.mashape.com/words/#{word}"
    response = HTTParty.get(url,
                  headers: {
                    "X-Mashape-Key" => ENV['MASHAPE_KEY'],
                    "Accept" => "application/json"
              })
    results = response['results']
    word_bases = results.map{|resp| {form: resp['partOfSpeech']} }
    pref_base = preferred_word_base(word_bases)
    entries = results.select{|entry| entry['partOfSpeech'] == pref_base[:form]}.reject{|entry| entry['instanceOf'] }
    definitions = entries.map{|entry| entry['definition']}
    if definitions.length > 1
      definitions = definitions[0..3].each_with_index.map do |defin, index| 
        "#{index + 1}. #{defin}"
      end
    end
    definitions_in_string = definitions.join("\t")
    Rails.cache.write("define_#{@word}", definitions_in_string, expires_in: 1.day)
    return definitions_in_string
  rescue
    oxford_definition
  end

  #get noun form first if noun form is a possible base, otherwise get verb, else get anything that comes first
  def preferred_word_base(word_bases)
    ["adjective", "adverb", "noun", "verb"].each do |form|
      base = word_bases.find{|word| word[:form].downcase == form }
      return base if base
    end
    word_base[0]
  end

  def full_match_indexes(target_word)
    @full_match_indexes ||= word.split('').map.each_with_index{ |letter, index| letter == target_word[index] ? index : nil }.compact
  end

  def partial_match_indexes(target_word)
    partial_or_full_match_indexes = word.split('').map.each_with_index{ |letter, index| target_word.include?(letter) ? index : nil }.compact
    @partial_match_count ||= partial_or_full_match_indexes - full_match_indexes(target_word)
  end
  
  def access_match(target_word)
    OpenStruct.new({
      full_match_indexes: full_match_indexes(target_word),
      partial_match_indexes: partial_match_indexes(target_word)
    })
  end

end

#binding.pry
