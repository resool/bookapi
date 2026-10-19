module Staff
  module Errors
    class MemberClosed < UnprocessableError
      def initialize(member_number:)
        super(I18n.t("staff_api.errors.member_closed", member_number:))
      end
    end
  end
end
