require "swagger_helper"

RSpec.describe "Staff API: list books", openapi_spec: "staff_api/v1/openapi.yaml" do
  path "/staff-api/v1/books" do
    get "List books with their status" do
      tags "Books"
      produces "application/json"
      OpenapiSchemas::PAGINATION_PARAMS.each { |param| parameter(param.deep_dup) }

      let!(:available) { create(:item, status: :available) }
      let!(:loaned) { create(:item, status: :loaned) }
      let!(:withdrawn) { create(:item, status: :withdrawn) }

      response "200", "books listed" do
        schema OpenapiSchemas.paginated(:book)

        context "without pagination params" do
          run_test! do |response|
            body = response.parsed_body
            expect(body["data"].pluck("sku")).to contain_exactly(available.sku, loaned.sku)
            expect(body["data"].pluck("status")).to contain_exactly("available", "loaned")
            expect(body["data"]).to all(satisfy { |book| !book.key?("loans") })
            expect(body["meta"]).to eq("page" => 1, "limit" => 20, "count" => 2, "pages" => 1)
          end
        end

        context "with page and limit" do
          let(:page) { 2 }
          let(:limit) { 1 }

          run_test! do |response|
            body = response.parsed_body
            expect(body["data"].pluck("sku")).to eq([ loaned.sku ])
            expect(body["meta"]).to eq("page" => 2, "limit" => 1, "count" => 2, "pages" => 2)
          end
        end
      end
    end
  end
end
