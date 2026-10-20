# :reek:InstanceVariableAssumption
class LoanReminderMailer < ApplicationMailer
  before_action :assign_loan

  def before_due_date
    mail(to: @member.email, subject: I18n.t("loan_reminder_mailer.before_due_date.subject", title: @edition.title))
  end

  def due_date
    mail(to: @member.email, subject: I18n.t("loan_reminder_mailer.due_date.subject", title: @edition.title))
  end

  private

  def assign_loan
    @loan = params.fetch(:loan)
    @member = @loan.member
    @edition = @loan.item.edition
  end
end
