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
        raise Errors::AuthorsMissing, "At least one author is required" if author_names.empty?

        isbn = Edition.normalize_value_for(:isbn, edition_attributes[:isbn])
        return if isbn.blank? || !Edition.exists?(isbn:)

        raise Errors::EditionAlreadyExists,
              "Edition with ISBN #{isbn} already exists; add a copy with POST /staff-api/v1/editions/:edition_id/books"
      end

      def find_or_create_authors
        author_names.map { |name| Author.create_or_find_by!(name:) }
      end
    end
  end
end
