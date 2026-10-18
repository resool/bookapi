require "swagger_helper"

RSpec.describe "Staff API: delete book", openapi_spec: "staff_api/v1/openapi.yaml", skip: "endpoint not implemented yet" do
  path "/staff-api/v1/books/{sku}" do
    delete "Withdraw a book copy (soft delete)" do
      tags "Books"
      produces "application/json"
      parameter name: :sku, in: :path, type: :string

      let(:item) { create(:item) }
      let(:sku) { item.sku }

      response "204", "book withdrawn" do
        run_test! do
          expect(item.reload).to be_withdrawn
        end
      end

      response "409", "book is currently loaned" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :book_loaned, "book_loaned", "Book 000123 is currently loaned and cannot be withdrawn"
        let(:item) { create(:item, status: :loaned) }

        before { create(:loan, item:) }

        run_test! do |response|
          expect(error_codes(response)).to include("book_loaned")
          expect(item.reload).to be_loaned
        end
      end

      response "404", "book not found" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :book_not_found, "book_not_found", "Book with SKU 000123 not found"

        context "when SKU does not exist" do
          let(:sku) { "missing" }

          run_test! do |response|
            expect(error_codes(response)).to include("book_not_found")
          end
        end

        context "when book is already withdrawn" do
          let(:item) { create(:item, status: :withdrawn) }

          run_test! do |response|
            expect(error_codes(response)).to include("book_not_found")
          end
        end
      end
    end
  end
end
