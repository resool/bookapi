module Staff
  module Errors
    class EditionAlreadyExists < UnprocessableError
      def initialize(isbn:)
        super(I18n.t("staff_api.errors.edition_already_exists", isbn:))
      end
    end
  end
end
