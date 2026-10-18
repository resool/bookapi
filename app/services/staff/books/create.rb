module Staff
  module Books
    class Create
      def initialize(edition:, sku:, condition:, acquired_on: nil)
        @edition = edition
        @sku = sku
        @condition = condition
        @acquired_on = acquired_on
      end

      def call
        edition.items.create!(sku:, condition:, acquired_on:, status: :available)
      end

      private

      attr_reader :edition, :sku, :condition, :acquired_on
    end
  end
end
