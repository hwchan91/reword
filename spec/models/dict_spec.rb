require "rails_helper"

RSpec.describe Dict, type: :model do
  before(:each) do
    @dict = Dict.new
  end

  describe "self.valid?" do
    it "should return a word if the word is valid, otherwise return nil" do
      expect(@dict.valid?('apple')).to eq('apple')
      expect(@dict.valid?('apply')).to eq('apply')
      expect(@dict.valid?('appl')).to eq(nil)
      expect(@dict.valid?('appllplp')).to eq(nil)
    end
  end
end