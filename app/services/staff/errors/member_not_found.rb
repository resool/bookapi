module Staff
  module Errors
    class MemberNotFound < UnprocessableError
      def initialize(member_number:)
        super(I18n.t("staff_api.errors.member_not_found", member_number:))
      end
    end
  end
end
