module Staff
  module Books
    class Create
      def initialize(edition:, condition:, acquired_on: nil)
        @edition = edition
        @condition = condition
        @acquired_on = acquired_on
      end

      def call
        edition.items.create!(sku: generated_sku, condition:, acquired_on:, status: :available)
      end

      private

      attr_reader :edition, :condition, :acquired_on

      def generated_sku
        loop do
          sku = SkuGenerator.new.call

          break sku unless Item.exists?(sku:)
        end
      end
    end
  end
end
