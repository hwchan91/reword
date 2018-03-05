class Level < ApplicationRecord
  require 'fileutils'
  require 'tempfile'

  serialize :path, Array
  scope :default, -> {where("id <= 50")}
  scope :automated, -> {where("auto IS TRUE")}
  scope :zen, -> {automated.where("created_at >= ?", 24.hours.ago)}

  @@words = Dict.new('popular').dict.keys


  def check_answer
    optimal = WordTrek.new(start, target).solve
    same_optimal = path.length == optimal.length
    [id, same_optimal, optimal]
  end

  def self.generate(start)
    associated_words = Word.new(start).associated_words
    remove_word_from_wordlist(start) && return if associated_words.empty?

    valid_levels = []
    associated_words.each do |target|
      path = WordTrek.new(start, target, 7).solve #limit solution to 7 turns
      if path.is_a?(Array) && path.length > 4 && path.length <=10
        valid_levels << level_hash(start, target, path)
      end
    end
    remove_word_from_wordlist(start) && return if valid_levels.empty?

    valid_levels
  end

  def self.level_hash(start, target, path)
    {id: 9999, start: start, target: target, path: path, limit: path.length}
  end

  def self.random
    # levels = nil
    # levels = generate(random_word) until levels
    # levels[rand(levels.size)]
    # @@all_zen_levels ||= JSON.parse(File.read('./zen_levels.json'))

    @@all_zen_levels[rand(@@all_zen_levels.count)]
  end

  def self.generate_all
    File.open("zen_levels.json", "w") { |f| f.puts("") }
    File.open("zen_levels.json", "a") { |f| f.puts("[") }
    final_word_index = @@words.count - 1
    @@words.each_with_index do |word, word_index|
      levels = generate(word)
      next unless levels
      File.open("zen_levels.json", "a") do |f|
        levels.each_with_index do |level, level_index|
          f.puts("  #{level.to_json}#{',' unless word_index == final_word_index && level_index == levels.count - 1 }")
        end
      end
    end
    File.open("zen_levels.json", "a") { |f| f.puts("]") }
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

  @@all_zen_levels = JSON.parse(File.read('./zen_levels.json'))
end
