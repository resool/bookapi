class Work < ApplicationRecord
  has_many :authorships, dependent: :destroy
  has_many :authors, through: :authorships
  has_many :editions, dependent: :restrict_with_error

  validates :title, presence: true
end
