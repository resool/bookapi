module Reminders
  # Reminds members N days before the due date (Settings.reminders.before_due_date.days_before).
  class BeforeDueDateChecker < BaseChecker
    private

    def settings
      Settings.reminders.before_due_date
    end

    def due_day
      Date.current + settings.days_before
    end

    def sent_column
      :before_due_date_reminder_sent_at
    end

    def mail_name
      :before_due_date
    end
  end
end
