# frozen_string_literal: true

require "rails_helper"

describe Staff::Loans::Return do
  subject(:call) { described_class.new(item:).call }

  let(:item) { create(:item, status: :loaned) }

  context "with an active loan" do
    let!(:loan) { create(:loan, item:) }

    it "closes the loan" do
      expect { call }.to change { loan.reload.returned_at }.from(nil)
    end

    it "makes the copy available" do
      expect { call }.to change { item.reload.status }.from("loaned").to("available")
    end
  end

  context "without an active loan" do
    let(:item) { create(:item, status: :available) }

    before { create(:loan, :returned, item:) }

    it "raises" do
      expect { call }.to raise_error(Staff::Errors::BookNotLoaned, "Book #{item.sku} is not currently loaned")
    end
  end
end
