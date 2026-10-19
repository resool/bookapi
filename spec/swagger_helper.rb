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

  AUTHORS = { type: :array, items: { type: :string }, example: [ "Lucy Maud Montgomery" ] }.freeze

  STAFF_BOOK_PROPERTIES = {
    sku: { type: :string, pattern: "^\\d{6}$", example: "000123" },
    condition: { type: :string, example: "good" },
    status: { type: :string, enum: %w[available loaned in_repair lost withdrawn], example: "available" },
    title: { type: :string, example: "Anne of Green Gables" },
    description: { type: :string, nullable: true, example: "An orphan girl is mistakenly sent to live with an elderly brother and sister on Prince Edward Island." },
    authors: AUTHORS
  }.freeze

  MEMBER = {
    type: :object,
    required: %w[member_number name email],
    properties: {
      member_number: { type: :string, pattern: "^\\d{6}$", example: "000042", description: "Library card number" },
      name: { type: :string, example: "Jan Kowalski" },
      email: { type: :string, format: :email, example: "jan.kowalski@example.com" }
    }
  }.freeze

  LOAN = {
    type: :object,
    required: %w[rented_at due_at returned_at member],
    properties: {
      rented_at: { type: :string, format: "date-time", example: "2026-10-01T10:15:00Z" },
      due_at: { type: :string, format: "date-time", example: "2026-10-31T10:15:00Z" },
      returned_at: { type: :string, format: "date-time", nullable: true, example: nil },
      member: MEMBER
    }
  }.freeze

  PAGINATION_META = {
    type: :object,
    required: %w[page limit count pages],
    properties: {
      page: { type: :integer, example: 1 },
      limit: { type: :integer, example: 20 },
      count: { type: :integer, example: 42, description: "Total number of records" },
      pages: { type: :integer, example: 3 }
    }
  }.freeze

  PAGINATION_PARAMS = [
    { name: :page, in: :query, required: false, schema: { type: :integer, minimum: 1, default: 1 } },
    { name: :limit, in: :query, required: false, schema: { type: :integer, minimum: 1, maximum: 100, default: 20 } }
  ].freeze

  module_function

  def data(ref)
    { type: :object, required: %w[data], properties: { data: { "$ref" => "#/components/schemas/#{ref}" } } }
  end

  def paginated(ref)
    {
      type: :object,
      required: %w[data meta],
      properties: {
        data: { type: :array, items: { "$ref" => "#/components/schemas/#{ref}" } },
        meta: { "$ref" => "#/components/schemas/pagination_meta" }
      }
    }
  end
end

module OpenapiErrorExamples
  def error_example(name, code, message)
    example "application/json", name, { errors: [ { code:, message: } ] }
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

  servers = [ { url: "http://localhost:3000" } ]

  config.openapi_specs = {
    "staff_api/v1/openapi.yaml" => {
      openapi: "3.0.1",
      info: { title: "Library Staff API", version: "v1" },
      paths: {},
      servers:,
      components: {
        schemas: {
          errors_object: OpenapiSchemas::ERRORS_OBJECT,
          pagination_meta: OpenapiSchemas::PAGINATION_META,
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
          pagination_meta: OpenapiSchemas::PAGINATION_META,
          book: {
            type: :object,
            required: %w[title description publisher published_year authors available_copies],
            additionalProperties: false,
            properties: {
              title: { type: :string, example: "Anne of Green Gables" },
              description: { type: :string, nullable: true, example: "An orphan girl is mistakenly sent to live with an elderly brother and sister on Prince Edward Island." },
              publisher: { type: :string, nullable: true, example: "L.C. Page & Co." },
              published_year: { type: :integer, nullable: true, example: 1908 },
              authors: OpenapiSchemas::AUTHORS,
              available_copies: { type: :integer, minimum: 0, example: 2, description: "Copies that can be borrowed right now; 0 means the book is currently unavailable" }
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
