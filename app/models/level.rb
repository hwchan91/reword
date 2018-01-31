class Level < ApplicationRecord
  require 'fileutils'
  require 'tempfile'

  serialize :path, Array
  scope :default, -> {where("id <= 50")}
  scope :automated, -> {where("auto IS TRUE")}
  scope :zen, -> {automated.where("created_at >= ?", 24.hours.ago)}

  @@words = Dict.new('popular').dict.keys

  def check
    optimal = WordTrek.new(start, target).solve
    same_optimal = path.length == optimal.length
    [id, same_optimal, optimal]
  end

  def self.generate
    valid = false
    start, target, path = nil, nil, nil
    until valid
      start = random_word
      associated_words = Word.new(start).associated_words.shuffle

      if associated_words.empty?
        remove_word_from_wordlist(start)
        next
      end

      associated_words.each do |word|
        target = word
        path = WordTrek.new(start, target, 7).solve #limit solution to 7 turns

        if path.is_a? Array and path.length > 4 and path.length <=10
          valid = true
          break
        end
      end
      remove_word_from_wordlist(start) if !valid
    end

    {id: 9999, start: start, target: target, path: path, limit: path.length}
  end

  def self.random_word
    @@words[rand(@@words.count)]
  end

  def self.remove_word_from_wordlist(word)
    tmp = Tempfile.new("custom_popular_temp")
    open('custom_popular_copy.txt', 'r').each { |l| tmp << l unless l.chomp == word }
    tmp.close
    FileUtils.mv(tmp.path, 'custom_popular_copy.txt')
  end
end
