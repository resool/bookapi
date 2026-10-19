# Makes an action safe to retry. A client sends the same Idempotency-Key header
# when it repeats a request (timeout, double click); the first successful response
# is stored and replayed instead of running the action again.
module Idempotency
  extend ActiveSupport::Concern

  HEADER = "Idempotency-Key"

  private

  def idempotent
    key = request.headers[HEADER]
    return yield if key.blank?

    record = IdempotencyKey.create_or_find_by!(key:) do |new_record|
      new_record.request_fingerprint = request_fingerprint
    end

    if record.previously_new_record?
      perform_and_store(record) { yield }
    else
      replay(record)
    end
  end

  def perform_and_store(record)
    yield

    if response.successful?
      record.complete!(status: response.status, body: response.body)
    else
      record.destroy!
    end
  rescue StandardError
    record.destroy!
    raise
  end

  def replay(record)
    if record.request_fingerprint != request_fingerprint
      render_errors(:unprocessable_content, [
        { code: "idempotency_key_reused", message: error_message("idempotency_key_reused") }
      ])
    elsif record.in_progress?
      render_errors(:conflict, [
        { code: "request_in_progress", message: error_message("request_in_progress") }
      ])
    else
      response.set_header("Idempotent-Replayed", "true")
      render json: record.response_body, status: record.response_status
    end
  end

  def request_fingerprint
    @request_fingerprint ||= IdempotencyKey.fingerprint(method: request.method, path: request.path, body: request.raw_post)
  end
end
