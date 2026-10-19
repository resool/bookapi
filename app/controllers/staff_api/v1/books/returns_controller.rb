module StaffApi
  module V1
    module Books
      class ReturnsController < BaseController
        # POST /staff-api/v1/books/:book_sku/return
        def create
          item = Item.find_by!(sku: params[:book_sku])
          Staff::Loans::Return.new(item:).call

          render_data(V1::BookSerializer.new(item).serializable_hash)
        end
      end
    end
  end
end
