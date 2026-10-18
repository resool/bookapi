# frozen_string_literal: true

require "rails_helper"

module OpenapiSchemas
  ERRORS_OBJECT = {
    type: :object,
    required: %w[errors],
    properties: {
      errors: {
        type: :array,
        items: {
          type: :object,
          required: %w[code message],
          properties: {
            code: { type: :string, example: "book_not_available" },
            message: { type: :string, example: "Book 000123 is currently loaned" }
          }
        }
      }
    }
  }.freeze

  AUTHORS = { type: :array, items: { type: :string }, example: ["Lucy Maud Montgomery"] }.freeze

  STAFF_BOOK_PROPERTIES = {
    sku: { type: :string, example: "000123" },
    condition: { type: :string, example: "good" },
    status: { type: :string, enum: %w[available loaned in_repair lost withdrawn], example: "available" },
    title: { type: :string, example: "Anne of Green Gables" },
    description: { type: :string, example: "An orphan girl is mistakenly sent to live with an elderly brother and sister on Prince Edward Island." },
    authors: AUTHORS
  }.freeze

  LOAN = {
    type: :object,
    required: %w[rented_at due_at returned_at member_number],
    properties: {
      rented_at: { type: :string, format: "date-time", example: "2026-10-01T10:15:00Z" },
      due_at: { type: :string, format: "date-time", example: "2026-10-31T10:15:00Z" },
      returned_at: { type: :string, format: "date-time", nullable: true, example: nil },
      member_number: { type: :string, example: "000042" }
    }
  }.freeze
end

module OpenapiErrorExamples
  def error_example(name, code, message)
    example "application/json", name, { errors: [{ code:, message: }] }
  end
end

RSpec.configure do |config|
  config.extend OpenapiErrorExamples, type: :request
  config.include(Module.new do
    def error_codes(response)
      response.parsed_body["errors"].pluck("code")
    end
  end, type: :request)

  config.openapi_root = Rails.root.join("swagger").to_s

  servers = [{ url: "http://localhost:3000" }]

  config.openapi_specs = {
    "staff_api/v1/openapi.yaml" => {
      openapi: "3.0.1",
      info: { title: "Library Staff API", version: "v1" },
      paths: {},
      servers:,
      components: {
        schemas: {
          errors_object: OpenapiSchemas::ERRORS_OBJECT,
          loan: OpenapiSchemas::LOAN,
          book: {
            type: :object,
            required: OpenapiSchemas::STAFF_BOOK_PROPERTIES.keys.map(&:to_s),
            properties: OpenapiSchemas::STAFF_BOOK_PROPERTIES
          },
          book_with_loans: {
            type: :object,
            required: OpenapiSchemas::STAFF_BOOK_PROPERTIES.keys.map(&:to_s) + %w[loans],
            properties: OpenapiSchemas::STAFF_BOOK_PROPERTIES.merge(
              loans: { type: :array, items: { "$ref" => "#/components/schemas/loan" } }
            )
          }
        }
      }
    },
    "public_api/v1/openapi.yaml" => {
      openapi: "3.0.1",
      info: { title: "Library Public API", version: "v1" },
      paths: {},
      servers:,
      components: {
        schemas: {
          book: {
            type: :object,
            required: %w[available title description authors],
            additionalProperties: false,
            properties: {
              available: { type: :boolean, example: true },
              title: { type: :string, example: "Anne of Green Gables" },
              description: { type: :string, example: "An orphan girl is mistakenly sent to live with an elderly brother and sister on Prince Edward Island." },
              authors: OpenapiSchemas::AUTHORS
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
