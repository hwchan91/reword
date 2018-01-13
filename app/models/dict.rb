class Dict
  attr_accessor :dict

  def initialize(custom_words = nil)
    @dict = case custom_words
            when nil then @@full_dict
            when 'common' then @@common_dict
            when 'popular' then @@popular_dict
            else Dict.generate_custom_words(custom_words)
            end
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
    #   not_all_caps = line[1..-1].downcase == line[1..-1]
    #   right_length = line.length.between?(3,7)
    #   if no_special_char and not_all_caps and right_length
    #     arr << line.downcase
    #   end
    # end

    text = File.open('./custom_word_list.txt').read
    text.each_line { |word| arr << word.strip }

    arr.each do |word|
      dict[word] = word
    end
    dict
  end

  def self.generate_popular
    dict = {}
    arr = []

    text = File.open('./popular.txt').read

    text.each_line do |word| 
      word = word.strip
      arr << word if word.length.between?(4,6) and !word[-1].in?(['o','u','x','a','z','i','s']) and !word[-2..-1].in?(['ed','ah','ic','if','er','wn','ue','ff','ee']) and !word[-3..-1].in?(['ing','ism','ual','och','uan']) and !word.split('').none?{|l| l.in? ['a','e','i','o','u'] } and !word.split('').any?{|l| l.in? ['z', 'x']}
    end
    common_dict = Dict.new('common').dict
    arr.reject!{|word| common_dict[word].nil? }
    arr.each { |word| dict[word] = word }
    dict
  end

  def self.generate_custom_words(words)
    dict = {}
    words.each{|w| dict[w] = w}
    dict
  end

  def valid?(word)
    @dict[word]
  end


  @@full_dict = Rails.cache.fetch("full_dict"){ Dict.generate }
  @@common_dict = Rails.cache.fetch("common_dict"){ Dict.generate_common }
  @@popular_dict = Rails.cache.fetch("popular_dict"){ Dict.generate_popular }

end
