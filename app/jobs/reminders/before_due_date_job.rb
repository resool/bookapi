module Reminders
  class BeforeDueDateJob < ApplicationJob
    queue_as :default

    # :reek:UtilityFunction
    def perform
      BeforeDueDateChecker.new.call
    end
  end
end
