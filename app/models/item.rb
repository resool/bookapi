class Item < ApplicationRecord
  SKU_FORMAT = /\A\d{6}\z/

  belongs_to :edition
  has_many :loans, -> { order(rented_at: :desc) }, dependent: :restrict_with_error, inverse_of: :item
  has_one :active_loan, -> { active }, class_name: "Loan"

  enum :status, {
    available: "available",
    loaned: "loaned",
    in_repair: "in_repair",
    lost: "lost",
    withdrawn: "withdrawn"
  }, validate: true

  validates :sku, presence: true, uniqueness: true, format: { with: SKU_FORMAT, message: "must be 6 digits" }
  validates :condition, presence: true
end
