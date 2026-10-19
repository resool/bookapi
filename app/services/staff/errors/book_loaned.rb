module Staff
  module Errors
    class BookLoaned < ConflictError
      def initialize(sku:)
        super(I18n.t("staff_api.errors.book_loaned", sku:))
      end
    end
  end
end
