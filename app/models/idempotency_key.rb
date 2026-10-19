class IdempotencyKey < ApplicationRecord
  # Uniqueness of `key` is enforced only by the unique index: a model-level uniqueness
  # validation would raise RecordInvalid and break `create_or_find_by!`, which relies
  # on the database raising RecordNotUnique for an existing key.
  validates :key, presence: true
  validates :request_fingerprint, presence: true

  def self.fingerprint(method:, path:, body:)
    Digest::SHA256.hexdigest([ method, path, body ].join("\n"))
  end

  def in_progress?
    response_status.nil?
  end

  def complete!(status:, body:)
    update!(response_status: status, response_body: body)
  end
end
