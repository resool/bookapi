require "rails_helper"

RSpec.describe Reminders::BeforeDueDateChecker do
  subject(:call) { described_class.new.call }

  around { |example| Timecop.freeze(Time.zone.local(2026, 10, 20, 8)) { example.run } }

  let!(:due_in_3_days) { create(:loan, due_at: Time.zone.local(2026, 10, 23, 18)) }

  before do
    create(:loan, due_at: Time.zone.local(2026, 10, 22, 18))                         # 2 days
    create(:loan, due_at: Time.zone.local(2026, 10, 24, 9))                          # 4 days
    create(:loan, :returned, rented_at: Time.zone.local(2026, 10, 1), due_at: Time.zone.local(2026, 10, 23, 12), returned_at: Time.zone.local(2026, 10, 19))
  end

  it "emails only active loans due in exactly 3 days" do
    expect { call }.to have_enqueued_mail(LoanReminderMailer, :before_due_date)
      .with(params: { loan: due_in_3_days }, args: []).exactly(:once)
  end

  it "records when the reminder was sent" do
    expect { call }.to change { due_in_3_days.reload.before_due_date_reminder_sent_at }.from(nil).to(Time.current)
  end

  it "doesn't email twice on the same day" do
    call

    expect { described_class.new.call }.not_to have_enqueued_mail(LoanReminderMailer, :before_due_date)
  end

  context "with a different number of days in settings" do
    let!(:due_in_5_days) { create(:loan, due_at: Time.zone.local(2026, 10, 25, 9)) }

    before { allow(Settings.reminders.before_due_date).to receive(:days_before).and_return(5) }

    it "uses the configured number of days" do
      expect { call }.to have_enqueued_mail(LoanReminderMailer, :before_due_date)
        .with(params: { loan: due_in_5_days }, args: []).exactly(:once)
    end
  end

  context "when disabled in settings" do
    before { allow(Settings.reminders.before_due_date).to receive(:enabled).and_return(false) }

    it "sends nothing" do
      expect { call }.not_to have_enqueued_mail
    end
  end
end
