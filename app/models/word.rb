class Word
  require_relative "dict"
  attr_accessor :word, :dict, :path, :index_changed

  def initialize(word, dict = nil, no_reorder = false, path = [], index_changed = nil)
    @word = word
    @dict = (dict.nil?) ? Dict.new : dict #cannot set default dict = Dict.new, because WordTrek passess nil as dict instead of nothing
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

  def get_definition
    begin
      inflection_url = "https://od-api.oxforddictionaries.com:443/api/v1/inflections/en/#{word}"
      inflection_response = HTTParty.get(inflection_url,
                                          headers: {
                                                    "Accept": "application/json",          
                                                    'app_id': ENV['OXFORD_ID'],
                                                    'app_key': ENV["OXFORD_KEY"] 
                                                    })
      if inflection_response['results']
        lexical_entries = inflection_response['results'][0]["lexicalEntries"]
        word_bases = lexical_entries.map{|entry| {
                                                  word: entry["inflectionOf"][0]["text"], 
                                                  form: entry["lexicalCategory"]} 
                                                }
        word_base = preferred_word_base(word_bases)
      end
      word_base = { word: @word, form: nil } if word_base.nil?
      
      definition_url = "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/#{word_base[:word]}"
      response =  HTTParty.get(definition_url,
                              headers: {
                                        "Accept": "application/json",          
                                        'app_id': ENV['OXFORD_ID'],
                                        'app_key': ENV["OXFORD_KEY"] 
                                        })
      
      if response['results']
        # occassionally, the lemma will return a form that does not exist in the entries
        begin
          entries = response['results'][0]['lexicalEntries'].find{|entry| entry['lexicalCategory'] == word_base[:form]}['entries']
        rescue
          entries = response['results'][0]['lexicalEntries'][0]['entries']
        end
        binding.pry
        definitions = entries.map{|entry| entry['senses'].map{|s| (s['definitions']) ? s['definitions'][0]: nil }}.compact
        definitions.map!{|entry| entry[0]}.reject!{|entry| entry.blank?}
        #response['results'][0]['lexicalEntries'][0]['entries'][0]['senses'].map{|s| s['definitions']}
        first_definitions = []
        if definitions.length > 1
          definitions.each_with_index do |defin, index| 
            first_definitions << "#{index + 1}. #{defin.capitalize}"
          end
        else
          first_definitions << "#{definitions[0].capitalize}"
        end
      end
      return first_definitions.join("\t")
    rescue
      return nil
    end
  end
  
  #get noun form first if noun form is a possible base, otherwise get verb, else get anything that comes first
  def preferred_word_base(word_bases)
    word_bases.find{|word| word[:form] == "Adjective"} ||
    word_bases.find{|word| word[:form] == "Adverb"} ||
    word_bases.find{|word| word[:form] == "Noun"} ||
    word_bases.find{|word| word[:form] == "Verb"} ||
    word_bases[0]
  end

end

#binding.pry