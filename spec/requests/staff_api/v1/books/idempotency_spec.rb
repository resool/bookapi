require "rails_helper"

RSpec.describe "Staff API: idempotent book creation" do
  let(:edition) { create(:edition) }
  let(:path) { "/staff-api/v1/editions/#{edition.id}/books" }
  let(:key) { "4b1e6a0e-6f0f-4c55-9a4c-3f1f6a1c2d10" }
  let(:params) { { condition: "new" } }

  def create_book(body: params, headers: { "Idempotency-Key" => key })
    post path, params: body, headers:, as: :json
  end

  context "when the same request is retried with the same key" do
    it "creates the book once and replays the first response" do
      expect { create_book }.to change(Item, :count).by(1)
      first_body = response.body

      expect { create_book }.not_to change(Item, :count)
      expect(response).to have_http_status(:created)
      expect(response.body).to eq(first_body)
      expect(response.headers["Idempotent-Replayed"]).to eq("true")
    end
  end

  context "when the key is reused with a different request" do
    before { create_book }

    it "rejects the request without creating a book" do
      expect { create_book(body: { condition: "worn" }) }.not_to change(Item, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(error_codes(response)).to eq([ "idempotency_key_reused" ])
    end
  end

  context "when the first request with the key is still being processed" do
    before do
      create(:idempotency_key, key:, request_fingerprint: IdempotencyKey.fingerprint(method: "POST", path:, body: params.to_json))
    end

    it "returns a conflict" do
      expect { create_book }.not_to change(Item, :count)
      expect(response).to have_http_status(:conflict)
      expect(error_codes(response)).to eq([ "request_in_progress" ])
    end
  end

  context "when the first request failed" do
    before { create_book(body: {}) }

    it "releases the key so a corrected request can use it" do
      expect(response).to have_http_status(:unprocessable_content)
      expect(IdempotencyKey.exists?(key:)).to be(false)

      expect { create_book }.to change(Item, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  context "without the header" do
    it "creates a book on every request" do
      expect { 2.times { create_book(headers: {}) } }.to change(Item, :count).by(2)
    end
  end

  def error_codes(response)
    response.parsed_body["errors"].pluck("code")
  end
end
