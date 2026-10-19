module Staff
  module Errors
    class BookNotLoaned < ConflictError
      def initialize(sku:)
        super(I18n.t("staff_api.errors.book_not_loaned", sku:))
      end
    end
  end
end
