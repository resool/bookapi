class Member < ApplicationRecord
  MEMBER_NUMBER_FORMAT = /\A\d{6}\z/

  has_many :loans, dependent: :restrict_with_error

  enum :status, {
    active: "active",
    suspended: "suspended",
    closed: "closed"
  }, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :member_number, :name, :email, presence: true
  validates :member_number, :email, uniqueness: true

  validates :member_number, format: { with: MEMBER_NUMBER_FORMAT, message: "must be 6 digits" }
end
