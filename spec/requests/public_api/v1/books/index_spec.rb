require "swagger_helper"

RSpec.describe "Public API: list books", openapi_spec: "public_api/v1/openapi.yaml" do
  path "/public-api/v1/books" do
    get "List book editions with availability" do
      tags "Books"
      produces "application/json"
      OpenapiSchemas::PAGINATION_PARAMS.each { |param| parameter(param.deep_dup) }

      let!(:solaris) { create(:edition, title: "Solaris") }
      let!(:mort) { create(:edition, title: "Mort") }
      let!(:hobbit) { create(:edition, title: "The Hobbit") }

      before do
        create_list(:item, 2, edition: solaris, status: :available)
        create(:item, edition: solaris, status: :loaned)
        create(:item, edition: mort, status: :loaned)
        create(:item, edition: hobbit, status: :in_repair)

        create(:item, edition: create(:edition, title: "Only withdrawn"), status: :withdrawn)
        create(:edition, title: "No copies")
      end

      response "200", "editions listed" do
        schema OpenapiSchemas.paginated(:book)

        context "without pagination params" do
          run_test! do |response|
            body = response.parsed_body

            expect(body["data"].map { |book| book.values_at("title", "available_copies") }).to eq([
              [ "Solaris", 2 ],
              [ "Mort", 0 ],
              [ "The Hobbit", 0 ]
            ])
            expect(body["meta"]).to eq("page" => 1, "limit" => 20, "count" => 3, "pages" => 1)
          end
        end

        context "with page and limit" do
          let(:page) { 2 }
          let(:limit) { 2 }

          run_test! do |response|
            body = response.parsed_body

            expect(body["data"].pluck("title")).to eq([ "The Hobbit" ])
            expect(body["meta"]).to eq("page" => 2, "limit" => 2, "count" => 3, "pages" => 2)
          end
        end

        context "without staff-only data" do
          run_test! do |response|
            book = response.parsed_body["data"].first

            expect(book.keys).to contain_exactly(
              "title", "description", "publisher", "published_year", "authors", "available_copies"
            )
          end
        end
      end
    end
  end
end
