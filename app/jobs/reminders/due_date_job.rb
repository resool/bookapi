module Reminders
  class DueDateJob < ApplicationJob
    queue_as :default

    # :reek:UtilityFunction
    def perform
      DueDateChecker.new.call
    end
  end
end
