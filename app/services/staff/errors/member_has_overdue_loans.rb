module Staff
  module Errors
    class MemberHasOverdueLoans < UnprocessableError
      def initialize(member_number:)
        super(I18n.t("staff_api.errors.member_has_overdue_loans", member_number:))
      end
    end
  end
end
