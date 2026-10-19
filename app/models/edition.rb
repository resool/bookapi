class Edition < ApplicationRecord
  belongs_to :work
  has_many :items, dependent: :restrict_with_error
  has_many :available_items, -> { available }, class_name: "Item", inverse_of: :edition
  has_many :authors, through: :work

  normalizes :isbn, with: ->(isbn) { isbn.delete("- ").presence }

  validates :title, presence: true
  validates :isbn, uniqueness: true, allow_nil: true

  scope :in_circulation, -> { where(id: Item.where.not(status: :withdrawn).pluck(:edition_id)) }
end
