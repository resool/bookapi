require "rails_helper"

RSpec.describe Author do
  subject { build(:author) }

  describe "associations" do
    it { is_expected.to have_many(:authorships).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:works).through(:authorships) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
