module StaffApi
  module V1
    class LoanSerializer
      include Alba::Resource

      attribute :rented_at do |object|
        object.rented_at.iso8601
      end
      attribute :due_at do |object|
        object.due_at.iso8601
      end
      attribute :returned_at do |object|
        object.returned_at&.iso8601
      end
      one :member, resource: MemberSerializer
    end
  end
end
