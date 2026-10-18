module PublicApi
  module V1
    class BooksController < BaseController
      # GET /public-api/v1/books
      def index
        head :not_implemented
      end
    end
  end
end
