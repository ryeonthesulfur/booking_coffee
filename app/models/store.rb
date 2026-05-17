class Store < ApplicationRecord
  has_many :seats, dependent: :destroy

  validates :name, presence: true
  validates :image_url, presence: true
  validates :smoking, inclusion: { in: [true, false] }
end
