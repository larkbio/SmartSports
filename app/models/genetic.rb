class Genetic < ActiveRecord::Base
  belongs_to :user
  belongs_to :genetics_type
  validates :user_id, presence: true
  validates :diabetes, presence: true
end
