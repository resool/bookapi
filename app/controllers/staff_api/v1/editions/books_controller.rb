module StaffApi
  module V1
    module Editions
      class BooksController < BaseController
        around_action :idempotent, only: :create

        # POST /staff-api/v1/editions/:edition_id/books
        def create
          edition = Edition.find(params[:edition_id])
          item = Staff::Books::Create.new(
            edition:,
            condition: params[:condition],
            acquired_on: params[:acquired_on]
          ).call

          render_data(V1::BookSerializer.new(item).serializable_hash, status: :created)
        end
      end
    end
  end
end
