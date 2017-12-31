class Dict
  attr_accessor :dict

  def initialize(custom_words = nil)
    @dict = case custom_words
            when nil then Rails.cache.fetch("full_dict"){ Dict.generate } #@@full_dict
            when 'common' then Rails.cache.fetch("common_dict"){ Dict.generate_common } #@@common_dict
            else Dict.generate_custom_words(custom_words)
            end
    #@dict = (custom_words.nil?) ? @@full_dict : Dict.generate_custom_words(custom_words)
  end

  def self.generate
    dict = {}
    text = File.open('./wordlist.txt').read
    text.gsub!(/\r\n?/, "\n")
    text.each_line do |line|
        word = line.strip()
        dict[word] = word
    end
    dict
  end
  #@@full_dict ||= Dict.generate

  def self.generate_common
    dict = {}
    arr = []

    # text = File.open('./american-82k.txt').read
    # text.gsub!(/\r\n?/, "\n")
    # text.each_line do |line|
    #   word = line.scan(/[\w']+/)[0]
    #   arr << word if word.length.between?(3,7)
    # end

    # text = File.open('./3of6all.txt').read
    # text.gsub!(/\r\n?/, "\n")
    # text.each_line do |line|
    #   line = line.strip
    #   no_special_char = line.scan(/[\w]+/)[0] == line
    #   not_all_caps = line.upcase != line
    #   right_length = line.length.between?(3,7)
    #   if no_special_char and not_all_caps and right_length
    #     arr << line.downcase
    #   end
    # end

    text = File.open('./custom_word_list.txt').read
    text.each_line { |word| arr << word.strip }

    # arr = arr.uniq
    arr.each do |word|
      dict[word] = word
    end
    dict
  end
  #@@common_dict ||= Dict.generate_common

  def self.generate_custom_words(words)
    dict = {}
    words.each{|w| dict[w] = w}
    dict
  end

  def valid?(word)
    @dict[word]
  end
end

#binding.pry
