require "swagger_helper"

RSpec.describe "Staff API: return book", openapi_spec: "staff_api/v1/openapi.yaml", skip: "endpoint not implemented yet" do
  path "/staff-api/v1/books/{sku}/return" do
    post "Return a borrowed book" do
      tags "Loans"
      produces "application/json"
      parameter name: :sku, in: :path, type: :string

      let(:item) { create(:item, status: :loaned) }
      let(:sku) { item.sku }

      response "200", "book returned" do
        schema OpenapiSchemas.data(:loan)
        example "application/json", :returned, {
          data: {
            rented_at: "2026-10-01T10:15:00Z",
            due_at: "2026-10-31T10:15:00Z",
            returned_at: "2026-10-12T16:40:00Z",
            member_number: "000042"
          }
        }

        let!(:loan) { create(:loan, item:) }

        run_test! do |response|
          expect(response.parsed_body.dig("data", "returned_at")).to be_present
          expect(loan.reload.returned_at).to be_present
          expect(item.reload).to be_available
        end
      end

      response "409", "book is not loaned" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :book_not_loaned, "book_not_loaned", "Book 000123 is not currently loaned"
        let(:item) { create(:item, status: :available) }

        run_test! do |response|
          expect(response.parsed_body["errors"].pluck("code")).to include("book_not_loaned")
        end
      end

      response "404", "book not found" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :book_not_found, "book_not_found", "Book with SKU 000123 not found"
        let(:sku) { "missing" }

        run_test! do |response|
          expect(error_codes(response)).to include("book_not_found")
        end
      end
    end
  end
end
