require "rails_helper"

RSpec.describe Dict, type: :model do

  describe "self.valid?" do
    it "should return a word if the word is valid, otherwise return nil" do
      expect(Dict.valid?('apple')).to eq('apple')
      expect(Dict.valid?('apply')).to eq('apply')
      expect(Dict.valid?('appl')).to eq(nil)
      expect(Dict.valid?('appllplp')).to eq(nil)
    end
  end
end