module PublicApi
  module V1
    # A book as readers see it: one entry per edition, with the number of copies
    # that can be borrowed right now. Individual copies (SKUs) stay internal.
    class BookSerializer
      include Alba::Resource

      attributes :title, :description, :publisher, :published_year

      attribute :authors do |edition|
        edition.work.authors.map(&:name)
      end

      attribute :available_copies do |edition|
        # `length` (not `size`) so Bullet sees the preloaded association as used
        edition.available_items.length
      end
    end
  end
end
