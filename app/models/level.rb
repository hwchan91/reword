class Level < ApplicationRecord
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

      next if associated_words.empty?

      associated_words.each do |word|
        target = word
        path = WordTrek.new(start, target, 7).solve #limit solution to 7 turns

        if path.is_a? Array and path.length > 4 and path.length <=10
          valid = true
          break
        end
      end
    end

    {id: 9999, start: start, target: target, path: path, limit: path.length}
  end

  def self.random_word
    @@words[rand(@@words.count)]
  end
end
