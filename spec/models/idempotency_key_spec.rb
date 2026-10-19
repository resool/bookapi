require "rails_helper"

RSpec.describe IdempotencyKey do
  subject(:idempotency_key) { build(:idempotency_key) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_presence_of(:request_fingerprint) }
    it { is_expected.to have_db_index(:key).unique }
  end

  describe ".fingerprint" do
    let(:base) { { method: "POST", path: "/staff-api/v1/editions/1/books", body: '{"condition":"new"}' } }

    it "is stable for the same request" do
      expect(described_class.fingerprint(**base)).to eq(described_class.fingerprint(**base))
    end

    it "differs when the body differs" do
      expect(described_class.fingerprint(**base)).not_to eq(described_class.fingerprint(**base, body: '{"condition":"worn"}'))
    end

    it "differs when the path differs" do
      expect(described_class.fingerprint(**base)).not_to eq(described_class.fingerprint(**base, path: "/staff-api/v1/editions/2/books"))
    end
  end

  describe "#in_progress?" do
    it { expect(build(:idempotency_key, response_status: nil)).to be_in_progress }
    it { expect(build(:idempotency_key, :completed)).not_to be_in_progress }
  end

  describe "#complete!" do
    subject(:idempotency_key) { create(:idempotency_key) }

    it "stores the response" do
      idempotency_key.complete!(status: 201, body: '{"data":{}}')

      expect(idempotency_key.reload).to have_attributes(response_status: 201, response_body: '{"data":{}}')
    end
  end
end
