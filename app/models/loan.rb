class Loan < ApplicationRecord
  belongs_to :item
  belongs_to :member

  validates_presence_of :rented_at, :due_at
  validates_uniqueness_of :item_id, if: :active?

  def active?
    !returned_at?
  end
end
