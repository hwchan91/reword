class Level < ApplicationRecord
  serialize :path, Array
  scope :default, -> {where("id <= 50")}
  scope :automated, -> {where("auto IS TRUE")}
  scope :zen, -> {automated.where("created_at >= ?", 24.hours.ago)}

  @@words = Dict.new('popular').dict.keys
  @@words_4 = @@words.select{|word| word.length == 4}
  @@words_5 = @@words.select{|word| word.length == 5}
  @@words_6 = @@words.select{|word| word.length == 6}

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
      associated_words = Word.new(start).associated_words

      next if associated_words.empty?

      associated_words.each do |word|
        target = word
        path = WordTrek.new(start, target, 8).solve #limit solution to 8 turns

        if path.is_a? Array and path.length > 4 and path.length <=10
          valid = true
          break
        end
      end
    end

    {id: 9999, start: start, target: target, path: path, limit: path.length}
  end

  def self.random_word
    words = class_variable_get("@@words_#{(4 + rand(3)).to_s}".to_sym)
    words[rand(words.count)]
  end
end
