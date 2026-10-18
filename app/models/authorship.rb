class Authorship < ApplicationRecord
  belongs_to :author
  belongs_to :work

  validates :author_id, uniqueness: { scope: :work_id }
end
