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
    it { is_expected.to validate_uniqueness_of(:member_number).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
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
