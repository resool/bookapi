class Author < ApplicationRecord
  has_many :authorships, dependent: :restrict_with_error
  has_many :works, through: :authorships

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true
end
