require "rails_helper"

RSpec.describe Loan do
  subject(:loan) { build(:loan, :active, item: item, returned_at: returned_at) }

  let(:item) { create(:item) }
  let(:returned_at) { nil }

  describe "associations" do
    it { is_expected.to belong_to(:item) }
    it { is_expected.to belong_to(:member) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:rented_at) }
    it { is_expected.to validate_presence_of(:due_at) }

    describe "one active loan per item" do
      context 'with another active loan' do
        before do
          create(:loan, :active, item: item)
        end

        it { is_expected.to be_invalid }
      end

      context 'with another returned loan' do
        before do
          create(:loan, :returned, item: item)
        end

        it { is_expected.to be_invalid }
      end
    end
  end

  describe "#active?" do
    subject(:active) { loan.active? }

    context 'with returned item' do
      let(:returned_at) { 1.day.ago }

      it { is_expected.to be_falsy }
    end

    context 'with not returned item' do
      let(:returned_at) { nil }

      it { is_expected.to be_truthy }
    end
  end
end
