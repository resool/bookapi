require "rails_helper"

RSpec.describe Reminders::DueDateChecker do
  subject(:call) { described_class.new.call }

  around { |example| Timecop.freeze(Time.zone.local(2026, 10, 20, 8)) { example.run } }

  let!(:due_today) { create(:loan, rented_at: Time.zone.local(2026, 9, 20, 18), due_at: Time.zone.local(2026, 10, 20, 18)) }

  before do
    create(:loan, rented_at: Time.zone.local(2026, 9, 19), due_at: Time.zone.local(2026, 10, 19, 18))  # overdue since yesterday
    create(:loan, due_at: Time.zone.local(2026, 10, 21, 9))                                             # tomorrow
  end

  it "emails only active loans due today" do
    expect { call }.to have_enqueued_mail(LoanReminderMailer, :due_date)
      .with(params: { loan: due_today }, args: []).exactly(:once)
  end

  it "records when the reminder was sent" do
    expect { call }.to change { due_today.reload.due_date_reminder_sent_at }.from(nil).to(Time.current)
  end

  it "doesn't email twice on the same day" do
    call

    expect { described_class.new.call }.not_to have_enqueued_mail(LoanReminderMailer, :due_date)
  end

  context "when disabled in settings" do
    before { allow(Settings.reminders.due_date).to receive(:enabled).and_return(false) }

    it "sends nothing" do
      expect { call }.not_to have_enqueued_mail
    end
  end
end
