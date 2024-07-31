class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :hilo

  validates :status, inclusion: { in: %w(like dislike boost) }
end
