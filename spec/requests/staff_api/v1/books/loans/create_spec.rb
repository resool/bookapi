require "swagger_helper"

RSpec.describe "Staff API: borrow book", openapi_spec: "staff_api/v1/openapi.yaml" do
  path "/staff-api/v1/books/{sku}/loans" do
    post "Borrow a book" do
      tags "Loans"
      consumes "application/json"
      produces "application/json"
      parameter name: :sku, in: :path, type: :string
      parameter name: :params, in: :body, schema: {
        type: :object,
        required: %w[member_number],
        properties: {
          member_number: { type: :string, pattern: "^\\d{6}$", example: "000042", description: "Library card number" }
        }
      }

      let(:item) { create(:item) }
      let(:member) { create(:member) }
      let(:sku) { item.sku }
      let(:params) { { member_number: member.member_number } }

      response "201", "book borrowed" do
        schema OpenapiSchemas.data(:loan)
        example "application/json", :borrowed, {
          data: {
            rented_at: "2026-10-01T10:15:00Z",
            due_at: "2026-10-31T10:15:00Z",
            returned_at: nil,
            member_number: "000042"
          }
        }

        run_test! do |response|
          expect(response.parsed_body.dig("data", "member_number")).to eq(member.member_number)
          expect(Time.zone.parse(response.parsed_body.dig("data", "due_at"))).to be_future
          expect(item.reload).to be_loaned
          expect(item.active_loan.member).to eq(member)
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

      response "409", "book not available" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :book_loaned, "book_not_available", "Book 000123 is currently loaned"
        error_example :book_in_repair, "book_not_available", "Book 000123 is in repair"

        context "when book is already loaned" do
          let(:item) { create(:item, status: :loaned) }

          before { create(:loan, item:) }

          run_test! do |response|
            expect(error_codes(response)).to include("book_not_available")
            expect(item.loans.active.count).to eq(1)
          end
        end

        context "when book is in repair" do
          let(:item) { create(:item, status: :in_repair) }

          run_test! do |response|
            expect(error_codes(response)).to include("book_not_available")
          end
        end
      end

      response "422", "member cannot borrow" do
        schema "$ref" => "#/components/schemas/errors_object"
        error_example :member_not_found, "member_not_found", "Member with card number 000042 not found"
        error_example :member_suspended, "member_suspended", "Member 000042 is suspended"
        error_example :member_has_overdue_loans, "member_has_overdue_loans", "Member 000042 has overdue loans"

        context "when member does not exist" do
          let(:params) { { member_number: "missing" } }

          run_test! do |response|
            expect(error_codes(response)).to include("member_not_found")
          end
        end

        context "when member is suspended" do
          let(:member) { create(:member, status: :suspended) }

          run_test! do |response|
            expect(error_codes(response)).to include("member_suspended")
            expect(item.reload).to be_available
          end
        end

        context "when member has overdue loans" do
          before do
            overdue_item = create(:item, status: :loaned)
            create(:loan, :overdue, item: overdue_item, member:)
          end

          run_test! do |response|
            expect(error_codes(response)).to include("member_has_overdue_loans")
            expect(item.reload).to be_available
          end
        end
      end
    end
  end
end
