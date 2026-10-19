require "rails_helper"

RSpec.describe "Reminder jobs" do
  {
    Reminders::BeforeDueDateJob => Reminders::BeforeDueDateChecker,
    Reminders::DueDateJob => Reminders::DueDateChecker
  }.each do |job_class, checker_class|
    describe job_class do
      it "runs #{checker_class}" do
        checker = instance_double(checker_class, call: nil)
        allow(checker_class).to receive(:new).and_return(checker)

        job_class.perform_now

        expect(checker).to have_received(:call)
      end
    end
  end
end
