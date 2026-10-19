# frozen_string_literal: true

require "rails_helper"

describe PublicApi::V1::BookSerializer do
  subject(:serializable_hash) { described_class.new(edition).serializable_hash }

  let(:edition) { create(:edition) }

  context "with copies in different statuses" do
    before do
      create_list(:item, 2, edition:, status: :available)
      create(:item, edition:, status: :loaned)
      create(:item, edition:, status: :withdrawn)
    end

    it "returns edition data with available copies count" do
      expect(serializable_hash).to match(
        "title" => edition.title,
        "description" => edition.description,
        "publisher" => edition.publisher,
        "published_year" => edition.published_year,
        "authors" => kind_of(Array),
        "available_copies" => 2
      )
    end
  end

  context "when no copy is available" do
    before do
      create(:item, edition:, status: :loaned)
      create(:item, edition:, status: :in_repair)
    end

    it { is_expected.to include("available_copies" => 0) }
  end

  context "with authors" do
    before do
      create(:authorship, work: edition.work, author: create(:author, name: "Terry Pratchett"))
      create(:authorship, work: edition.work, author: create(:author, name: "Neil Gaiman"))
    end

    it { expect(serializable_hash["authors"]).to contain_exactly("Terry Pratchett", "Neil Gaiman") }
  end
end
