require "swagger_helper"

RSpec.describe "Staff API: create book", openapi_spec: "staff_api/v1/openapi.yaml" do
  path "/staff-api/v1/editions/{edition_id}/books" do
    post "Add a book copy to an edition" do
      tags "Books"
      consumes "application/json"
      produces "application/json"
      parameter name: :edition_id, in: :path, type: :integer
      parameter name: :params, in: :body, schema: {
        type: :object,
        required: %w[sku condition],
        properties: {
          sku: { type: :string, example: "000123" },
          condition: { type: :string, example: "new" },
          acquired_on: { type: :string, format: :date }
        }
      }

      let(:edition) { create(:edition) }
      let(:edition_id) { edition.id }
      let(:params) { { sku: "000123", condition: "new" } }

      response "201", "book created" do
        schema "$ref" => "#/components/schemas/book"

        run_test! do |response|
          body = response.parsed_body
          expect(body).to include("sku" => "000123", "status" => "available", "title" => edition.title)
          expect(edition.items.find_by(sku: "000123")).to be_available
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
        error_example :sku_taken, "validation_failed", "Sku has already been taken"
        error_example :condition_missing, "validation_failed", "Condition can't be blank"

        context "when SKU is already taken" do
          before { create(:item, sku: "000123") }

          run_test! do |response|
            expect(error_codes(response)).to include("validation_failed")
          end
        end

        context "when condition is missing" do
          let(:params) { { sku: "000123" } }

          run_test! do |response|
            expect(error_codes(response)).to include("validation_failed")
          end
        end
      end
    end
  end
end
