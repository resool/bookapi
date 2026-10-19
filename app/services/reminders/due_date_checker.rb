module Reminders
  # Reminds members on the day the book is due.
  class DueDateChecker < BaseChecker
    private

    def settings
      Settings.reminders.due_date
    end

    def due_day
      Date.current
    end

    def sent_column
      :due_date_reminder_sent_at
    end

    def mail_name
      :due_date
    end
  end
end
