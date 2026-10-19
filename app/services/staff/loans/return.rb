module Staff
  module Loans
    # Closes the active loan of a copy and makes the copy available again.
    class Return
      def initialize(item:)
        @item = item
      end

      def call
        Item.transaction do
          loan = item.loans.active.lock.first
          raise Errors::BookNotLoaned.new(sku: item.sku) unless loan

          loan.update!(returned_at: Time.current)
          item.available!
        end
      end

      private

      attr_reader :item
    end
  end
end
