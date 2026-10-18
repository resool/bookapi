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
    it { is_expected.to validate_uniqueness_of(:sku).ignoring_case_sensitivity }
    it { is_expected.to validate_presence_of(:condition) }

    describe "sku format" do
      it { is_expected.to allow_values("000123", "999999").for(:sku) }
      it { is_expected.not_to allow_values("12345", "1234567", "12345a", "12 345", "-12345").for(:sku).with_message("must be 6 digits") }
    end
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
