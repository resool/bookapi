require "rails_helper"

RSpec.describe LoanReminderMailer do
  let(:member) { create(:member, name: "Anna Nowak", email: "anna@example.com") }
  let(:edition) { create(:edition, title: "Solaris") }
  let(:item) { create(:item, edition:, sku: "000123", status: :loaned) }
  let(:loan) { create(:loan, item:, member:, rented_at: Time.zone.local(2026, 10, 1, 10), due_at: Time.zone.local(2026, 10, 31, 10)) }

  describe "#before_due_date" do
    subject(:mail) { described_class.with(loan:).before_due_date }

    it "is sent to the member" do
      expect(mail.to).to eq([ "anna@example.com" ])
      expect(mail.from).to eq([ "library@example.com" ])
      expect(mail.subject).to eq('Reminder: "Solaris" is due in a few days')
    end

    it "names the book, copy and due date" do
      expect(mail.body.encoded).to include("Hi Anna Nowak", '"Solaris" (copy 000123)', "October 31, 2026")
    end
  end

  describe "#due_date" do
    subject(:mail) { described_class.with(loan:).due_date }

    it "is sent to the member" do
      expect(mail.to).to eq([ "anna@example.com" ])
      expect(mail.subject).to eq('"Solaris" is due today')
    end

    it "says the book is due today" do
      expect(mail.body.encoded).to include("is due back today", "October 31, 2026")
    end
  end
end
