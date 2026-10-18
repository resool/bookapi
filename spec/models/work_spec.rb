require "rails_helper"

RSpec.describe Work do
  subject { build(:work) }

  describe "associations" do
    it { is_expected.to have_many(:authorships).dependent(:destroy) }
    it { is_expected.to have_many(:authors).through(:authorships) }
    it { is_expected.to have_many(:editions).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
  end
end
