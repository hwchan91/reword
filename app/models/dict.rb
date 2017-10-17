class Dict

  def initialize(custom_words = nil)
    @dict = (custom_words.nil?) ? @@full_dict : Dict.generate_custom_words(custom_words)
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
  @@full_dict ||= Dict.generate

  def self.generate_custom_words(words)
    dict = {}
    words.each{|w| dict[w] = w}
    dict
  end

  def valid?(word)
    @dict[word]
  end
end

