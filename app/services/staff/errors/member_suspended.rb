module Staff
  module Errors
    class MemberSuspended < UnprocessableError
      def initialize(member_number:)
        super(I18n.t("staff_api.errors.member_suspended", member_number:))
      end
    end
  end
end
