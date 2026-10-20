module Reminders
  # Reminds members on the day the book is due.
  class DueDateChecker < BaseChecker
    private

    # :reek:UtilityFunction
    def settings
      Settings.reminders.due_date
    end

    # :reek:UtilityFunction
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
