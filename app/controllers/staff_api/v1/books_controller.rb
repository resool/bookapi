module StaffApi
  module V1
    class BooksController < BaseController
      # GET /staff-api/v1/books
      def index
        items = Item.where.not(status: :withdrawn).includes(edition: { work: :authors }).order(:id)

        render_paginated(items, serializer: BookSerializer)
      end

      # GET /staff-api/v1/books/:sku
      def show
        item = Item.includes(edition: { work: :authors }, loans: :member).find_by!(sku: params[:sku])

        render_data(BookSerializer.new(item, with_traits: :with_loans).serializable_hash)
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

        render_data(BookSerializer.new(item).serializable_hash, status: :created)
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
