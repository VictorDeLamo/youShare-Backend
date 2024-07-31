# app/views/hilos/show.json.jbuilder
json.extract! @hilo, :id, :title, :content, :created_at, :updated_at, :likes, :dislikes, :boosts_count, :url

# Información del propietario del hilo
json.propietario do
  json.id @hilo.user.id
  json.username @hilo.user.username
end
if @hilo.magazine
  json.magazine do
    json.extract! @hilo.magazine, :id, :name, :title
  end
else
  json.magazine nil
end
# Comentarios del hilo
json.comments build_nested_comments(@hilo.comments.where(parent_id: nil), params[:comments_order])

json.comments_count @hilo.comments.count
# Incluir información de reacciones
json.user_reactions @user_reactions
json.comment_reactions @comment_reactions
