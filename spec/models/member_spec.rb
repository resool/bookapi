require "rails_helper"

RSpec.describe Member do
  subject { build(:member) }

  describe "associations" do
    it { is_expected.to have_many(:loans).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:member_number) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:member_number).ignoring_case_sensitivity }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }

    describe "member_number format" do
      it { is_expected.to allow_values("000042", "999999").for(:member_number) }
      it { is_expected.not_to allow_values("4242", "1234567", "00004x", "000 42").for(:member_number).with_message("must be 6 digits") }
    end
  end

  describe "status" do
    it do
      expect(subject).to define_enum_for(:status)
        .with_values(active: "active", suspended: "suspended", closed: "closed")
        .backed_by_column_of_type(:enum)
        .validating
    end
  end

  describe "normalization" do
    it { is_expected.to normalize(:email).from("  Jan.Kowalski@Example.COM ").to("jan.kowalski@example.com") }
  end
end
