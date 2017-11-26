class Level < ApplicationRecord
  serialize :path, Array

  def check
    optimal = WordTrek.new(start, target, Dict.new("common")).continue_until_solution_found.first
    same_optimal = path.length == optimal.length
    [id, same_optimal, optimal]
  end
end
