require "rails_helper"

RSpec.describe Item do
  subject { build(:item) }

  describe "associations" do
    it { is_expected.to belong_to(:edition) }
    it { is_expected.to have_many(:loans).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:active_loan).class_name("Loan") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:sku) }
    it { is_expected.to validate_uniqueness_of(:sku).case_insensitive }
    it { is_expected.to validate_presence_of(:condition) }
  end

  describe "status" do
    it do
      expect(subject).to define_enum_for(:status)
        .with_values(
          available: "available",
          loaned: "loaned",
          in_repair: "in_repair",
          lost: "lost",
          withdrawn: "withdrawn"
        )
        .backed_by_column_of_type(:enum)
        .validating
    end
  end
end
