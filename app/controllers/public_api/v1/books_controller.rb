module PublicApi
  module V1
    class BooksController < BaseController
      # GET /public-api/v1/books
      def index
        editions = Edition.in_circulation.includes(:available_items, work: :authors).order(:id)

        render_paginated(editions, serializer: BookSerializer)
      end
    end
  end
end
