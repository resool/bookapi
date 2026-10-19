module Staff
  module Books
    class Remove
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

        raise Staff::Errors::BookLoaned.new(sku: item.sku)
      end

      def mark_as_removed
        item.withdrawn!
      end
    end
  end
end
