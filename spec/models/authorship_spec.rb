require "rails_helper"

RSpec.describe Authorship do
  subject { build(:authorship) }

  describe "associations" do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to belong_to(:work) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:author_id).scoped_to(:work_id) }
  end
end
