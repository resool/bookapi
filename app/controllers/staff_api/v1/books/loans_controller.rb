module StaffApi
  module V1
    module Books
      class LoansController < BaseController
        around_action :idempotent, only: :create

        # POST /staff-api/v1/books/:book_sku/loans
        def create
          item = Item.find_by!(sku: params[:book_sku])
          member = Member.find_by(member_number: params[:member_number])
          raise Staff::Errors::MemberNotFound, "Member with card number #{params[:member_number]} not found" unless member

          loan = Staff::Loans::Create.new(item:, member:).call

          render_data(V1::LoanSerializer.new(loan).serializable_hash, status: :created)
        end
      end
    end
  end
end
