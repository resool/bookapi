module ApiResponses
  extend ActiveSupport::Concern
  include Pagy::Method

  private

  def render_data(data, status: :ok)
    render json: { data: }, status:
  end

  def render_paginated(collection, serializer:, **serializer_options)
    pagy, records = pagy(:offset, collection)

    render json: {
      data: serializer.new(records, **serializer_options).serializable_hash,
      meta: pagination_meta(pagy)
    }
  end

  def pagination_meta(pagy)
    { page: pagy.page, limit: pagy.limit, count: pagy.count, pages: pagy.last }
  end
end
