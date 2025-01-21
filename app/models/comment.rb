class Comment < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :shop_id, presence: true
  validates :sentence, presence: true
end
