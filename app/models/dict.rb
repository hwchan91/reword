module Dict
  
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
  @@dict = Dict.generate

  def self.valid?(word)
    @@dict[word]
  end
end

