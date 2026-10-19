require "swagger_helper"

RSpec.describe "Staff API: add new book", openapi_spec: "staff_api/v1/openapi.yaml" do
  path "/staff-api/v1/books" do
    post "Add a new book (title, authors, first copy)" do
      tags "Books"
      description "Creates the work, its authors (matched by name) and the edition, then the first copy with a generated SKU. " \
                  "To add another copy of a book the library already has, use POST /staff-api/v1/editions/{edition_id}/books."
      consumes "application/json"
      produces "application/json"
      parameter name: "Idempotency-Key", in: :header, required: false, schema: { type: :string, format: :uuid },
                description: "Send the same key when retrying a request; a repeated key replays the first response " \
                             "instead of creating another book."
      parameter name: :params, in: :body, schema: {
        type: :object,
        required: %w[title authors condition],
        properties: {
          title: { type: :string, example: "Good Omens" },
          authors: { type: :array, minItems: 1, items: { type: :string }, example: [ "Terry Pratchett", "Neil Gaiman" ] },
          condition: { type: :string, example: "new" },
          description: { type: :string, example: "The apocalypse, but funny." },
          publisher: { type: :string, example: "Gollancz" },
          published_year: { type: :integer, example: 1990 },
          isbn: { type: :string, example: "978-0-575-04800-3" },
          translator: { type: :string }
        }
      }

      let(:params) { { title: "Good Omens", authors: [ "Terry Pratchett", "Neil Gaiman" ], condition: "new" } }

      response "201", "book created" do
        schema OpenapiSchemas.data(:book)

        context "with required fields only" do
          run_test! do |response|
            body = response.parsed_body["data"]

            expect(body).to include("title" => "Good Omens", "status" => "available", "condition" => "new", "description" => nil)
            expect(body["authors"]).to contain_exactly("Terry Pratchett", "Neil Gaiman")
            expect(body["sku"]).to match(Item::SKU_FORMAT)
          end
        end

        context "with an author that already exists" do
          before { create(:author, name: "Terry Pratchett") }

          run_test! do
            expect(Author.where(name: "Terry Pratchett").count).to eq(1)
          end
        end

        context "with edition details" do
          let(:params) do
            {
              title: "Good Omens", authors: [ "Terry Pratchett" ], condition: "good",
              description: "The apocalypse, but funny.", publisher: "Gollancz", published_year: 1990, isbn: "978-0-575-04800-3"
            }
          end

          run_test! do |response|
            edition = Item.find_by!(sku: response.parsed_body.dig("data", "sku")).edition

            expect(edition).to have_attributes(publisher: "Gollancz", published_year: 1990, isbn: "9780575048003")
          end
        end
      end

      response "422", "invalid params" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :authors_missing, "authors_missing", "At least one author is required"
        error_example :edition_already_exists, "edition_already_exists",
                      "Edition with ISBN 9780575048003 already exists; add a copy with POST /staff-api/v1/editions/:edition_id/books"
        error_example :title_missing, "validation_failed", "Title can't be blank"

        context "without authors" do
          let(:params) { { title: "Good Omens", authors: [], condition: "new" } }

          run_test! do |response|
            expect(error_codes(response)).to eq([ "authors_missing" ])
          end
        end

        context "when an edition with the ISBN already exists" do
          let(:params) { { title: "Good Omens", authors: [ "Terry Pratchett" ], condition: "new", isbn: "9780575048003" } }

          before { create(:edition, isbn: "978-0-575-04800-3") }

          run_test! do |response|
            expect(error_codes(response)).to eq([ "edition_already_exists" ])
            expect(Work.where(title: "Good Omens")).to be_empty
          end
        end

        context "without title" do
          let(:params) { { authors: [ "Terry Pratchett" ], condition: "new" } }

          run_test! do |response|
            expect(response.parsed_body["errors"].pluck("message")).to include("Title can't be blank")
          end
        end

        context "without condition" do
          let(:params) { { title: "Good Omens", authors: [ "Terry Pratchett" ] } }

          run_test! do |response|
            expect(response.parsed_body["errors"].pluck("message")).to include("Condition can't be blank")
            expect(Work.where(title: "Good Omens")).to be_empty
          end
        end
      end
    end
  end
end
