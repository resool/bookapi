# frozen_string_literal: true

require "rails_helper"

describe Staff::Books::Remove do
  subject(:service) { described_class.new(item:) }

  describe "#call" do
    subject(:call) { service.call }

    %i[ available in_repair lost ].each do |status|
      context "when book is #{status}" do
        let(:item) { create(:item, status:) }

        it "withdraws the book" do
          expect { call }.to change { item.reload.status }.from(status.to_s).to("withdrawn")
        end
      end
    end

    context "when book is loaned" do
      let(:item) { create(:item, status: :loaned, sku: "000123") }

      before { create(:loan, item:) }

      it "raises a conflict error and keeps the book loaned" do
        expect { call }.to raise_error(
          Staff::Errors::BookLoaned,
          "Book 000123 is currently loaned and cannot be withdrawn"
        ).and not_change { item.reload.status }
      end
    end
  end
end

