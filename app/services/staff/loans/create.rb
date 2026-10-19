module Staff
  module Loans
    class Create
      def initialize(item:, member:)
        @item = item
        @member = member
        @now = Time.current
      end

      def call
        validate_member!

        loan_book
      end

      private

      attr_reader :item, :member, :now

      def validate_member!
        raise Errors::MemberSuspended, "Member #{member.member_number} is suspended" if member.suspended?
        raise Errors::MemberClosed, "Member #{member.member_number} has a closed account" if member.closed?
        return unless member.loans.overdue.exists?

        raise Errors::MemberHasOverdueLoans, "Member #{member.member_number} has overdue loans"
      end

      def loan_book
        Item.transaction do
          claim_item!
          Loan.create!(item:, member:, rented_at: now, due_at: now + Settings.loan_period_days.days)
        end
      end

      def claim_item!
        claimed = Item.where(id: item.id, status: :available).update_all(status: "loaned", updated_at: now)
        raise_not_available if claimed.zero?
      end

      def raise_not_available
        raise Errors::BookNotAvailable, "Book #{item.sku} is not available"
      end
    end
  end
end
