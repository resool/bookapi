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

      # :reek:DuplicateMethodCall
      def validate_member!
        raise Errors::MemberSuspended.new(member_number: member.member_number) if member.suspended?
        raise Errors::MemberClosed.new(member_number: member.member_number) if member.closed?
        return unless member.loans.overdue.exists?

        raise Errors::MemberHasOverdueLoans.new(member_number: member.member_number)
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
        raise Errors::BookNotAvailable.new(sku: item.sku)
      end
    end
  end
end
