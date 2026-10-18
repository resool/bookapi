require "swagger_helper"

RSpec.describe "Public API: list books", openapi_spec: "public_api/v1/openapi.yaml", skip: "endpoint not implemented yet" do
  path "/public-api/v1/books" do
    get "List books with availability" do
      tags "Books"
      produces "application/json"
      OpenapiSchemas::PAGINATION_PARAMS.each { |param| parameter(param.deep_dup) }

      let!(:available) { create(:item, status: :available) }
      let!(:loaned) { create(:item, status: :loaned) }

      before do
        create(:loan, item: loaned)
        create(:item, status: :withdrawn)
      end

      response "200", "books listed" do
        schema OpenapiSchemas.paginated(:book)

        run_test! do |response|
          body = response.parsed_body
          expect(body["data"].pluck("title")).to contain_exactly(available.edition.title, loaned.edition.title)
          expect(body["data"].pluck("available")).to contain_exactly(true, false)
          expect(body["meta"]).to include("count" => 2)
        end
      end
    end
  end
end
