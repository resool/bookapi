require "swagger_helper"

RSpec.describe "Staff API: list books", openapi_spec: "staff_api/v1/openapi.yaml" do
  path "/staff-api/v1/books" do
    get "List books with their status" do
      tags "Books"
      produces "application/json"

      let!(:available) { create(:item, status: :available) }
      let!(:loaned) { create(:item, status: :loaned) }
      let!(:withdrawn) { create(:item, status: :withdrawn) }

      response "200", "books listed" do
        schema type: :array, items: { "$ref" => "#/components/schemas/book" }

        run_test! do |response|
          body = response.parsed_body
          expect(body.pluck("sku")).to contain_exactly(available.sku, loaned.sku)
          expect(body.pluck("status")).to contain_exactly("available", "loaned")
          expect(body).to all(satisfy { |book| !book.key?("loans") })
        end
      end
    end
  end
end
