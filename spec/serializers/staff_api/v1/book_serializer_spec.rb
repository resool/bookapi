# frozen_string_literal: true

describe StaffApi::V1::BookSerializer do
  subject(:serializer) { described_class.new(item, **opts) }

  let(:opts) { {} }
  let(:item) { create(:item, loans: [ build(:loan, :active), build(:loan, :returned) ]) }

  describe '.serializable_hash' do
    subject(:serializable_hash) { serializer.serializable_hash }

    context 'without with_loans trait' do
      let(:expected_data) do
        {
          sku: kind_of(String),
          title: kind_of(String),
          condition: kind_of(String),
          description: kind_of(String),
          authors: kind_of(Array),
          status: kind_of(String)
        }.stringify_keys
      end

      it 'returns expected data' do
        expect(serializable_hash).to match(expected_data)
      end
    end

    context 'with with_loans trait' do
      let(:opts) { { with_traits: :with_loans } }

      let(:expected_data) do
        {
          sku: kind_of(String),
          title: kind_of(String),
          condition: kind_of(String),
          loans: kind_of(Array),
          description: kind_of(String),
          authors: kind_of(Array),
          status: kind_of(String)
        }.stringify_keys
      end

      it 'returns expected data' do
        expect(serializable_hash).to match(expected_data)
      end
    end
  end
end
