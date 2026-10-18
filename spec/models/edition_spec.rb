require "rails_helper"

RSpec.describe Edition do
  subject { build(:edition) }

  describe "associations" do
    it { is_expected.to belong_to(:work) }
    it { is_expected.to have_many(:items).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:publisher) }
    it { is_expected.to validate_presence_of(:published_year) }
    it { is_expected.to validate_uniqueness_of(:isbn).allow_nil.case_insensitive }
  end

  describe "normalization" do
    it { is_expected.to normalize(:isbn).from("978-83-240-0123-4").to("9788324001234") }
    it { is_expected.to normalize(:isbn).from("").to(nil) }
  end
end
