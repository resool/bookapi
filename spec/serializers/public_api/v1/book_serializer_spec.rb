# frozen_string_literal: true

describe PublicApi::V1::BookSerializer do
  subject(:serializer) { described_class.new(item) }

  let(:item) { create(:item, status: status) }
  let(:status) { :available }

  describe '.serializable_hash' do
    subject(:serializable_hash) { serializer.serializable_hash }

    context 'with available status' do
      let(:expected_data) do
        {
          available: true,
          title: kind_of(String),
          description: kind_of(String),
          authors: kind_of(Array)
        }.stringify_keys
      end

      it 'returns expected data' do
        expect(serializable_hash).to match(expected_data)
      end
    end

    (Item.statuses.keys - [ 'available' ]).each do |status_name|
      context "with #{status_name} status" do
        let(:status) { status_name }

        let(:expected_data) do
          {
            available: false,
            title: kind_of(String),
            description: kind_of(String),
            authors: kind_of(Array)
          }.stringify_keys
        end

        it 'returns expected data' do
          expect(serializable_hash).to match(expected_data)
        end
      end
    end
  end
end
