module StaffApi
  module V1
    class BooksController < BaseController
      # GET /staff-api/v1/books
      def index
        head :not_implemented
      end

      # GET /staff-api/v1/books/:sku
      def show
        head :not_implemented
      end

      # POST /staff-api/v1/editions/:edition_id/books
      def create
        head :not_implemented
      end

      # DELETE /staff-api/v1/books/:sku
      def destroy
        head :not_implemented
      end
    end
  end
end
