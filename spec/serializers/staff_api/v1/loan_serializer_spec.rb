# frozen_string_literal: true

describe StaffApi::V1::LoanSerializer do
  subject(:serializer) { described_class.new(loan) }

  describe '.serializable_hash' do
    subject(:serializable_hash) { serializer.serializable_hash }

    context 'with active loan' do
      let(:loan) { build(:loan, :active) }

      let(:expected_data) do
        {
          rented_at: kind_of(String),
          due_at: kind_of(String),
          returned_at: nil,
          member_number: kind_of(String)
        }.stringify_keys
      end

      it 'returns expected data' do
        expect(serializable_hash).to match(expected_data)
      end
    end

    context 'with returned loan' do
      let(:loan) { build(:loan, :returned) }

      let(:expected_data) do
        {
          rented_at: kind_of(String),
          due_at: kind_of(String),
          returned_at: kind_of(String),
          member_number: kind_of(String)
        }.stringify_keys
      end

      it 'returns expected data' do
        expect(serializable_hash).to match(expected_data)
      end
    end
  end
end
