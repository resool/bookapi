# frozen_string_literal: true

require "rails_helper"

describe Staff::Loans::Create do
  subject(:call) { described_class.new(item:, member:).call }

  let(:item) { create(:item, status: :available) }
  let(:member) { create(:member) }

  around { |example| Timecop.freeze(Time.zone.local(2026, 10, 1, 10, 15)) { example.run } }

  context "with an available copy and an active member" do
    it "creates a loan for the configured period" do
      expect(call).to have_attributes(
        item:,
        member:,
        rented_at: Time.zone.local(2026, 10, 1, 10, 15),
        due_at: Time.zone.local(2026, 10, 31, 10, 15),
        returned_at: nil
      )
    end

    it "marks the copy as loaned" do
      expect { call }.to change { item.reload.status }.from("available").to("loaned")
    end
  end

  %i[ loaned in_repair lost withdrawn ].each do |status|
    context "when the copy is #{status}" do
      let(:item) { create(:item, status:) }

      it "raises and creates no loan" do
        expect { call }.to raise_error(Staff::Errors::BookNotAvailable, "Book #{item.sku} is not available")
          .and not_change(Loan, :count)
      end
    end
  end

  context "when the copy was borrowed by someone else in the meantime" do
    before { Item.where(id: item.id).update_all(status: "loaned") }

    it "does not trust the stale in-memory status" do
      expect(item).to be_available
      expect { call }.to raise_error(Staff::Errors::BookNotAvailable)
    end
  end

  context "when the member is suspended" do
    let(:member) { create(:member, status: :suspended) }

    it "raises and leaves the copy available" do
      expect { call }.to raise_error(Staff::Errors::MemberSuspended)
        .and not_change { item.reload.status }
    end
  end

  context "when the member account is closed" do
    let(:member) { create(:member, status: :closed) }

    it { expect { call }.to raise_error(Staff::Errors::MemberClosed) }
  end

  context "when the member has an overdue loan" do
    before { create(:loan, :overdue, member:, item: create(:item, status: :loaned)) }

    it "raises and leaves the copy available" do
      expect { call }.to raise_error(Staff::Errors::MemberHasOverdueLoans)
        .and not_change { item.reload.status }
    end
  end

  context "when the member returned an overdue book late" do
    before { create(:loan, :overdue, member:, returned_at: 1.day.ago) }

    it "allows borrowing" do
      expect { call }.to change(Loan, :count).by(1)
    end
  end
end
