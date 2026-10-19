module Staff
  module Errors
    class BookNotAvailable < ConflictError
      def initialize(sku:)
        super(I18n.t("staff_api.errors.book_not_available", sku:))
      end
    end
  end
end
