module Staff
  module Errors
    class AuthorsMissing < UnprocessableError
      def initialize
        super(I18n.t("staff_api.errors.authors_missing"))
      end
    end
  end
end
