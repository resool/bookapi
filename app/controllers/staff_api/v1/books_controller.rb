module StaffApi
  module V1
    class BooksController < BaseController
      # GET /staff-api/v1/books
      def index
        items = Item.where.not(status: :withdrawn).includes(edition: { work: :authors })

        render json: BookSerializer.new(items).serialize
      end

      # GET /staff-api/v1/books/:sku
      def show
        item = Item.includes(edition: { work: :authors }, loans: :member).find_by!(sku: params[:sku])

        render json: BookSerializer.new(item, with_traits: :with_loans).serialize
      end

      # POST /staff-api/v1/editions/:edition_id/books
      def create
        edition = Edition.find(params[:edition_id])
        item = Staff::Books::Create.new(
          edition:,
          sku: params[:sku],
          condition: params[:condition],
          acquired_on: params[:acquired_on]
        ).call

        render json: BookSerializer.new(item).serialize, status: :created
      end

      # DELETE /staff-api/v1/books/:sku
      def destroy
        item = Item.where.not(status: :withdrawn).find_by!(sku: params[:sku])
        Staff::Books::Remove.new(item:).call

        head :no_content
      end
    end
  end
end
