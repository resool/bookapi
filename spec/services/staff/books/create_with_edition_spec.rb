# frozen_string_literal: true

require "rails_helper"

describe Staff::Books::CreateWithEdition do
  subject(:call) { described_class.new(**params).call }

  let(:params) do
    {
      title: title,
      authors: authors,
      condition: condition,
      description: description,
      publisher: publisher,
      published_year: published_year,
      isbn: isbn,
      translator: translator
    }
  end

  let(:title) { "Good Omens" }
  let(:authors) { [ "Terry Pratchett", "Neil Gaiman" ] }
  let(:condition) { "new" }
  let(:description) { nil }
  let(:isbn) { nil }
  let(:publisher) { nil }
  let(:published_year) { nil }
  let(:translator) { nil }

  context 'with valid params' do
    it "creates the work, edition and first copy" do
      expect { call }.to change(Work, :count).by(1)
        .and change(Edition, :count).by(1)
        .and change(Item, :count).by(1)
    end

    it "returns an available copy of the new edition" do
      expect(call).to be_available
      expect(call.edition).to have_attributes(title: "Good Omens")
      expect(call.edition.work).to have_attributes(title: "Good Omens")
    end

    it "assigns the authors to the work" do
      expect(call.edition.work.authors.map(&:name)).to contain_exactly("Terry Pratchett", "Neil Gaiman")
    end
  end

  context 'with invalid params' do
    context "when an author already exists" do
      let!(:pratchett) { create(:author, name: "Terry Pratchett") }

      it "reuses the existing author" do
        expect { call }.to change(Author, :count).by(1)
        expect(call.edition.work.authors).to include(pratchett)
      end
    end

    context "with duplicated and messy author names" do
      let(:authors) { [ " Terry  Pratchett ", "Terry Pratchett", "" ] }

      it "creates each author once" do
        expect(call.edition.work.authors.map(&:name)).to eq([ "Terry Pratchett" ])
      end
    end

    context "with edition details" do
      let(:description) { "Funny apocalypse." }
      let(:publisher) { "Gollancz" }
      let(:published_year) { 1990 }
      let(:isbn) { "978-0-575-04800-3" }

      it "stores them on the edition" do
        expect(call.edition).to have_attributes(description:, publisher:, published_year:, isbn: "9780575048003")
      end
    end

    context "without authors" do
      let(:authors) { [] }

      it "raises without creating anything" do
        expect { call }.to raise_error(Staff::Errors::AuthorsMissing)
          .and not_change(Work, :count)
      end
    end

    context "when an edition with the ISBN already exists" do
      let(:isbn) { "9780575048003" }

      before { create(:edition, isbn: "978-0-575-04800-3") }

      it "raises without creating anything" do
        expect { call }.to raise_error(Staff::Errors::EditionAlreadyExists)
          .and not_change(Work, :count)
      end
    end

    context "when the copy is invalid" do
      let(:condition) { nil }

      it "rolls back the work, edition and authors" do
        expect { call }.to raise_error(ActiveRecord::RecordInvalid)
          .and not_change(Work, :count)
          .and not_change(Edition, :count)
          .and not_change(Author, :count)
      end
    end
  end
end
