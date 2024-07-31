class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :hilo
  validates :content, length: { in: 0..10000 }, presence: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :comment_reactions, dependent: :destroy
  has_many :comment_boosts, dependent: :destroy, counter_cache: true

  # Método para calcular la profundidad del comentario
  def depth
    ancestor_count = 0
    current_comment = self
    while current_comment.parent_id
      ancestor_count += 1
      current_comment = current_comment.parent
    end
    ancestor_count
  end
end
