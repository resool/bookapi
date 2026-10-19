module Reminders
  class DueDateJob < ApplicationJob
    queue_as :default

    def perform
      DueDateChecker.new.call
    end
  end
end
