class Loan < ApplicationRecord
  belongs_to :item
  belongs_to :member

  scope :active, -> { where(returned_at: nil) }
  scope :overdue, -> { active.where(due_at: ...Time.current) }

  validates :rented_at, :due_at, presence: true
  validates :item_id, uniqueness: { conditions: -> { active } }, if: :active?

  def active?
    !returned_at?
  end
end
