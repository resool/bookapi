module ApiErrorHandling
  extend ActiveSupport::Concern

  NOT_FOUND_CODES = {
    "Item" => "book_not_found",
    "Edition" => "edition_not_found"
  }.freeze

  included do
    rescue_from ActiveRecord::RecordNotFound do |error|
      code = NOT_FOUND_CODES.fetch(error.model, "not_found")
      render_errors(:not_found, [ { code:, message: error_message(code) } ])
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      errors = error.record.errors.full_messages.map { |message| { code: "validation_failed", message: } }
      render_errors(:unprocessable_content, errors)
    end

    rescue_from Staff::Errors::ConflictError do |error|
      render_errors(:conflict, [ { code: error.code, message: error.message } ])
    end

    rescue_from Staff::Errors::UnprocessableError do |error|
      render_errors(:unprocessable_content, [ { code: error.code, message: error.message } ])
    end
  end

  private

  # staff_api.errors.* or public_api.errors.*,
  def error_message(code)
    I18n.t(code, scope: "#{controller_path.split("/").first}.errors", default: :not_found)
  end

  def render_errors(status, errors)
    render json: { errors: }, status:
  end
end
