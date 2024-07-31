class CommentReaction < ApplicationRecord
  belongs_to :comment
  belongs_to :user

  validates :status, presence: true, inclusion: { in: %w(like dislike boost) }
end
