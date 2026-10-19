module Reminders
  # Finds active loans that are due on a given day and haven't been reminded yet,
  # sends the reminder email and records when it was sent, so running the check
  # again on the same day (a retry, a second cron run) doesn't email twice.
  #
  # Subclasses define: #settings (Settings.reminders.<name>), #due_day, #sent_column, #mail_name.
  class BaseChecker
    def initialize
      @now = Time.current
    end

    def call
      return unless settings.enabled

      loans.find_each do |loan|
        LoanReminderMailer.with(loan:).public_send(mail_name).deliver_later
        loan.update!(sent_column => now)
      end
    end

    def loans
      Loan.active.where(due_at: due_day.all_day, sent_column => nil)
    end

    private

    attr_reader :now
  end
end
