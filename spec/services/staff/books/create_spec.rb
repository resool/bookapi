# frozen_string_literal: true

require "rails_helper"

describe Staff::Books::Create do
  subject(:service) { described_class.new(edition:, condition:, acquired_on:) }

  let(:edition) { create(:edition) }
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
        condition: "new",
        acquired_on: Date.new(2026, 10, 1)
      )
    end

    it "assigns a generated 6-digit SKU" do
      expect(call.sku).to match(Item::SKU_FORMAT)
    end

    it "marks the copy as available" do
      expect(call).to be_available
    end

    context "without acquired_on" do
      subject(:service) { described_class.new(edition:, condition:) }

      it { expect(call.acquired_on).to be_nil }
    end

    context "when generated SKU is already taken" do
      let(:generator) { instance_double(Staff::Books::SkuGenerator) }

      before do
        create(:item, sku: "000123")
        allow(Staff::Books::SkuGenerator).to receive(:new).and_return(generator)
        allow(generator).to receive(:call).and_return("000123", "000456")
      end

      it "generates another SKU" do
        expect(call.sku).to eq("000456")
        expect(generator).to have_received(:call).twice
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
