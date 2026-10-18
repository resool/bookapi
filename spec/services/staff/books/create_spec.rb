# frozen_string_literal: true

require "rails_helper"

describe Staff::Books::Create do
  subject(:service) { described_class.new(edition:, sku:, condition:, acquired_on:) }

  let(:edition) { create(:edition) }
  let(:sku) { "000123" }
  let(:condition) { "new" }
  let(:acquired_on) { Date.new(2026, 10, 1) }

  describe "#call" do
    subject(:call) { service.call }

    it "creates a book copy for the edition" do
      expect { call }.to change(edition.items, :count).by(1)
    end

    it "returns the created copy with given attributes" do
      expect(call).to have_attributes(
        edition:,
        sku: "000123",
        condition: "new",
        acquired_on: Date.new(2026, 10, 1)
      )
    end

    it "marks the copy as available" do
      expect(call).to be_available
    end

    context "without acquired_on" do
      subject(:service) { described_class.new(edition:, sku:, condition:) }

      it { expect(call.acquired_on).to be_nil }
    end

    context "when SKU is already taken" do
      before { create(:item, sku:) }

      it "raises a validation error without creating a copy" do
        expect { call }.to raise_error(ActiveRecord::RecordInvalid, /Sku has already been taken/)
          .and not_change(Item, :count)
      end
    end

    context "when condition is missing" do
      let(:condition) { nil }

      it "raises a validation error without creating a copy" do
        expect { call }.to raise_error(ActiveRecord::RecordInvalid, /Condition can't be blank/)
          .and not_change(Item, :count)
      end
    end
  end
end
