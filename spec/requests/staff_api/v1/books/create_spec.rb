require "swagger_helper"

RSpec.describe "Staff API: create book", openapi_spec: "staff_api/v1/openapi.yaml" do
  path "/staff-api/v1/editions/{edition_id}/books" do
    post "Add a book copy to an edition" do
      tags "Books"
      consumes "application/json"
      produces "application/json"
      parameter name: :edition_id, in: :path, type: :integer
      parameter name: "Idempotency-Key", in: :header, required: false, schema: { type: :string, format: :uuid },
                description: "Send the same key when retrying a request; a repeated key replays the first response " \
                             "instead of creating another copy."
      parameter name: :params, in: :body, schema: {
        type: :object,
        required: %w[condition],
        properties: {
          condition: { type: :string, example: "new" },
          acquired_on: { type: :string, format: :date }
        }
      }

      let(:edition) { create(:edition) }
      let(:edition_id) { edition.id }
      let(:params) { { condition: "new" } }

      response "201", "book created" do
        schema OpenapiSchemas.data(:book)

        run_test! do |response|
          body = response.parsed_body["data"]
          expect(body).to include("status" => "available", "title" => edition.title)
          expect(body["sku"]).to match(Item::SKU_FORMAT)
          expect(edition.items.find_by(sku: body["sku"])).to be_available
        end
      end

      response "409", "request with this Idempotency-Key is still being processed" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :request_in_progress, "request_in_progress", "A request with this Idempotency-Key is still being processed"

        let(:"Idempotency-Key") { "4b1e6a0e-6f0f-4c55-9a4c-3f1f6a1c2d10" }

        before do
          create(:idempotency_key, key: send(:"Idempotency-Key"),
                                   request_fingerprint: IdempotencyKey.fingerprint(method: "POST", path: "/staff-api/v1/editions/#{edition_id}/books", body: params.to_json))
        end

        run_test! do |response|
          expect(error_codes(response)).to include("request_in_progress")
        end
      end

      response "404", "edition not found" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :edition_not_found, "edition_not_found", "Edition with id 42 not found"
        let(:edition_id) { 0 }

        run_test! do |response|
          expect(error_codes(response)).to include("edition_not_found")
        end
      end

      response "422", "invalid params" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :condition_missing, "validation_failed", "Condition can't be blank"
        error_example :idempotency_key_reused, "idempotency_key_reused", "Idempotency-Key was already used with a different request"

        context "when condition is missing" do
          let(:params) { {} }

          run_test! do |response|
            expect(response.parsed_body["errors"].pluck("message")).to include("Condition can't be blank")
          end
        end

        context "when Idempotency-Key was used with a different request" do
          let(:"Idempotency-Key") { "4b1e6a0e-6f0f-4c55-9a4c-3f1f6a1c2d10" }

          before { create(:idempotency_key, :completed, key: send(:"Idempotency-Key")) }

          run_test! do |response|
            expect(error_codes(response)).to include("idempotency_key_reused")
          end
        end
      end
    end
  end
end
