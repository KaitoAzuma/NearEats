class Bookmark < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: { scope: :shop_id }
end
