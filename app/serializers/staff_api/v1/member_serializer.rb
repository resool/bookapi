module StaffApi
  module V1
    class MemberSerializer
      include Alba::Resource

      attributes :member_number, :name, :email
    end
  end
end
