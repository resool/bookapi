require "swagger_helper"

RSpec.describe "Staff API: show book", openapi_spec: "staff_api/v1/openapi.yaml" do
  path "/staff-api/v1/books/{sku}" do
    get "Show a book with its full loan history" do
      tags "Books"
      produces "application/json"
      parameter name: :sku, in: :path, type: :string

      let(:item) { create(:item, status: :loaned) }
      let(:sku) { item.sku }

      response "200", "book with loan history" do
        schema OpenapiSchemas.data(:book_with_loans)

        book = {
          sku: "000123",
          condition: "good",
          title: "Anne of Green Gables",
          description: "An orphan girl is mistakenly sent to live with an elderly brother and sister on Prince Edward Island.",
          authors: [ "Lucy Maud Montgomery" ]
        }
        anna = { member_number: "000017", name: "Anna Nowak", email: "anna.nowak@example.com" }
        jan = { member_number: "000042", name: "Jan Kowalski", email: "jan.kowalski@example.com" }
        maria = { member_number: "000108", name: "Maria Wiśniewska", email: "maria.w@example.com" }
        # newest first
        past_loans = [
          { rented_at: "2026-08-11T12:00:00Z", due_at: "2026-09-10T12:00:00Z",
            returned_at: "2026-09-14T10:20:00Z", member: jan },
          { rented_at: "2026-06-02T09:30:00Z", due_at: "2026-07-02T09:30:00Z",
            returned_at: "2026-06-14T17:05:00Z", member: anna }
        ]

        example "application/json", :currently_loaned, data: book.merge(
          status: "loaned",
          loans: [
            { rented_at: "2026-10-01T10:15:00Z", due_at: "2026-10-31T10:15:00Z",
              returned_at: nil, member: maria }
          ] + past_loans
        )
        example "application/json", :available, data: book.merge(status: "available", loans: past_loans)

        let(:past_reader) { create(:member) }
        let(:current_reader) { create(:member) }

        before do
          create(:loan, :returned, item:, member: past_reader, rented_at: 1.month.ago, due_at: 2.weeks.ago,
                                   returned_at: 3.weeks.ago)
          create(:loan, item:, member: current_reader)
        end

        run_test! do |response|
          loans = response.parsed_body.dig("data", "loans")

          expect(loans.map { |loan| loan.dig("member", "member_number") })
            .to eq([ current_reader.member_number, past_reader.member_number ]) # newest first
          expect(loans.first["member"]).to eq(
            "member_number" => current_reader.member_number, "name" => current_reader.name, "email" => current_reader.email
          )
          expect(loans.first["returned_at"]).to be_nil
          expect(loans.last["returned_at"]).to be_present
        end
      end

      response "404", "book not found" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :book_not_found, "book_not_found", "Book not found"
        let(:sku) { "missing" }

        run_test! do |response|
          expect(error_codes(response)).to include("book_not_found")
        end
      end
    end
  end
end
