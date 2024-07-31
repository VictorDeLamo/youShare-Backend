module HilosHelper
  include ActionView::Helpers::DateHelper

  def time_since_creation(hilo)
    time_ago_in_words(hilo.created_at) + ' ago'
  end

  def build_nested_comments(comments, order_by = nil)
    ordered_comments = order_comments(comments, order_by)
    ordered_comments.map do |comment|
      {
        id: comment.id,
        hilo_id: comment.hilo_id,
        parent_id: comment.parent_id,
        content: comment.content,
        created_at: comment.created_at,
        updated_at: comment.updated_at,
        likes: comment.likes,
        dislikes: comment.dislikes,
        boosts: comment.boosts_count,
        user_id: comment.user_id,
        username: comment.user.username,
        replies: build_nested_comments(comment.replies, order_by) # Usar la relación 'replies' para los comentarios hijos
      }
    end
  end

  def order_comments(comments, order_param)
    case order_param
    when 'top'
      comments.order(Arel.sql('likes - dislikes DESC'))
    when 'newest'
      comments.order(created_at: :desc)
    when 'older'
      comments.order(created_at: :asc)
    else
      comments
    end
  end
end
