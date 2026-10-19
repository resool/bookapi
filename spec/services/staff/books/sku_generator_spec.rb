# frozen_string_literal: true

require "rails_helper"

describe Staff::Books::SkuGenerator do
  subject(:generator) { described_class.new }

  describe "#call" do
    subject(:call) { generator.call }

    it "returns a 6-digit string" do
      expect(call).to match(Item::SKU_FORMAT)
    end

    it "pads small numbers with leading zeros" do
      allow(SecureRandom).to receive(:random_number).with(1_000_000).and_return(42)

      expect(call).to eq("000042")
    end
  end
end
