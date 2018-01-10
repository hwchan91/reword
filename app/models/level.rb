class Level < ApplicationRecord
  serialize :path, Array
  scope :default, -> {where("id <= 50")}
  scope :automated, -> {where("auto IS TRUE")}
  scope :zen, -> {automated.where("created_at >= ?", 24.hours.ago)}

  @@words = Dict.new('common').dict.keys
  @@words_4 = @@words.select{|word| word.length == 4}
  @@words_5 = @@words.select{|word| word.length == 5}
  @@words_6 = @@words.select{|word| word.length == 6}

  def check
    optimal = WordTrek.new(start, target, Dict.new("common")).continue_until_solution_found.first
    same_optimal = path.length == optimal.length
    [id, same_optimal, optimal]
  end

  def self.generate_daily_zen
    150.times { Level.generate }
  end

  def self.generate
    words = class_variable_get("@@words_#{(4 + rand(3)).to_s}".to_sym)
    valid = false
    until valid
      start = random_word(words)
      target = random_word(words)
      path = WordTrek.new(start, target).solve
      valid = true unless path == "no solution" or path.length <= 6 or duplicated_level(start, target)
    end

    {id: 9999, start: start, target: target, path: path, limit: path.length}
    #Level.create({start: start, target: target, path: path, limit: path.length, auto: true})
  end

  def self.random_word(words)
    words[rand(words.count)]
  end

  def self.duplicated_level(start, target)
    Level.find_by(start: start, target: target) or Level.find_by(start: target, target: start)
  end
end
