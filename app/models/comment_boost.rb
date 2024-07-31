class CommentBoost < ApplicationRecord
  belongs_to :comment, counter_cache: :boosts_count
  belongs_to :user
end
