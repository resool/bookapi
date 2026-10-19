# frozen_string_literal: true

require "rails_helper"

describe Staff::Errors::BookLoaned do
  subject(:error) { described_class.new }

  it { is_expected.to be_a(Staff::Errors::ConflictError) }
  it { expect(error.code).to eq("book_loaned") }
end
