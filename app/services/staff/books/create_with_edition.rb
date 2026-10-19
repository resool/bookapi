module Staff
  module Books
    class CreateWithEdition
      def initialize(title:, authors:, condition:, description:, publisher:, published_year:, isbn:, translator:)
        @title = title
        @author_names = Array(authors).map { |name| name.to_s.squish }.compact_blank.uniq
        @condition = condition
        @edition_attributes = { description:, publisher:, published_year:, isbn:, translator: }
      end

      def call
        validate!

        ActiveRecord::Base.transaction do
          work = Work.create!(title:, description: edition_attributes[:description], authors: find_or_create_authors)
          edition = work.editions.create!(title:, **edition_attributes)

          Create.new(edition:, condition:).call
        end
      end

      private

      attr_reader :title, :author_names, :condition, :edition_attributes

      def validate!
        raise Errors::AuthorsMissing if author_names.empty?

        isbn = Edition.normalize_value_for(:isbn, edition_attributes[:isbn])
        return if isbn.blank? || !Edition.exists?(isbn:)

        raise Errors::EditionAlreadyExists.new(isbn:)
      end

      def find_or_create_authors
        author_names.map { |name| Author.create_or_find_by!(name:) }
      end
    end
  end
end
