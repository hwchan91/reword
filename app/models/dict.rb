#require 'pry'
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
    text = File.open('./american-82k.txt').read
    text.gsub!(/\r\n?/, "\n")
    text.each_line do |line|
      word = line.scan(/[\w']+/)[0]
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
