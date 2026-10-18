class Author < ApplicationRecord
  has_many :authorships, dependent: :restrict_with_error
  has_many :works, through: :authorships

  validates :name, presence: true
end
