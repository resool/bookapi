# frozen_string_literal: true

require "rails_helper"

describe Staff::Errors::BookLoaned do
  subject(:error) { described_class.new(sku: "000123") }

  it { is_expected.to be_a(Staff::Errors::ConflictError) }
  it { expect(error.code).to eq("book_loaned") }
  it { expect(error.message).to eq("Book 000123 is currently loaned and cannot be withdrawn") }
end
