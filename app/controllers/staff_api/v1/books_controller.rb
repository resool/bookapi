module StaffApi
  module V1
    class BooksController < BaseController
      around_action :idempotent, only: :create

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

      # POST /staff-api/v1/books
      def create
        item = Staff::Books::CreateWithEdition.new(
          title: params[:title],
          authors: params[:authors],
          condition: params[:condition],
          description: params[:description],
          publisher: params[:publisher],
          published_year: params[:published_year],
          isbn: params[:isbn],
          translator: params[:translator]
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
