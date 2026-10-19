# Preview at http://localhost:3000/rails/mailers/loan_reminder_mailer (needs at least one loan in the database).
class LoanReminderMailerPreview < ActionMailer::Preview
  def before_due_date
    LoanReminderMailer.with(loan: Loan.last).before_due_date
  end

  def due_date
    LoanReminderMailer.with(loan: Loan.last).due_date
  end
end
