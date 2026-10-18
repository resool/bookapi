class Member < ApplicationRecord
  has_many :loans, dependent: :restrict_with_error

  enum :status, {
    active: "active",
    suspended: "suspended",
    closed: "closed"
  }, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :member_number, :name, :email, presence: true
  validates :member_number, :email, uniqueness: true
end
