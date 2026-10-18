module PublicApi
  module V1
    class BookSerializer
      include Alba::Resource

      attribute :available do |object|
        object.available?
      end
      attribute :title do |object|
        object.edition.title
      end
      attribute :description do |object|
        object.edition.description
      end

      attribute :authors do |object|
        object.edition.work.authors.map(&:name)
      end
    end
  end
end
