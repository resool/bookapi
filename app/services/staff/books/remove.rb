module Staff
  module Books
    class Remove
      class BookLoaned < Staff::ConflictError
      end

      def initialize(item:)
        @item = item
      end

      def call
        validate!
        mark_as_removed
      end

      private

      attr_reader :item

      def validate!
        return unless item.loaned?

        raise BookLoaned, "Book #{item.sku} is currently loaned and cannot be withdrawn"
      end

      def mark_as_removed
        item.withdrawn!
      end
    end
  end
end
