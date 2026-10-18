class Edition < ApplicationRecord
  belongs_to :work
  has_many :items, dependent: :restrict_with_error
  has_many :authors, through: :work

  normalizes :isbn, with: ->(isbn) { isbn.delete("- ").presence }

  validates :title, :description, :publisher, :published_year, presence: true
  validates :isbn, uniqueness: true, allow_nil: true
end
