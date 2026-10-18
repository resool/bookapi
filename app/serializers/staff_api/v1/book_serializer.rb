module StaffApi
  module V1
    class BookSerializer
      include Alba::Resource

      attributes :sku, :condition, :status
      attribute :title do |object|
        object.edition.title
      end
      attribute :description do |object|
        object.edition.description
      end

      attribute :authors do |object|
        object.edition.work.authors.map(&:name)
      end

      trait :with_loans do
        many :loans, resource: LoanSerializer
      end
    end
  end
end
