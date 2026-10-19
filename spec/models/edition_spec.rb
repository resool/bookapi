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

  describe "circulation" do
    let(:edition) { create(:edition) }
    let!(:available) { create(:item, edition:, status: :available) }
    let!(:loaned) { create(:item, edition:, status: :loaned) }

    before { create(:item, edition:, status: :withdrawn) }

    it "includes only available copies in available items" do
      expect(edition.available_items).to contain_exactly(available)
    end

    describe ".in_circulation" do
      it "includes editions with at least one copy that is not withdrawn" do
        only_withdrawn = create(:edition)
        create(:item, edition: only_withdrawn, status: :withdrawn)
        without_copies = create(:edition)

        expect(described_class.in_circulation).to include(edition)
        expect(described_class.in_circulation).not_to include(only_withdrawn, without_copies)
      end
    end
  end

  describe "normalization" do
    it { is_expected.to normalize(:isbn).from("978-83-240-0123-4").to("9788324001234") }
    it { is_expected.to normalize(:isbn).from("").to(nil) }
  end
end
