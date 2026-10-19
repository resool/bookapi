module Reminders
  class BeforeDueDateJob < ApplicationJob
    queue_as :default

    def perform
      BeforeDueDateChecker.new.call
    end
  end
end
