# app/views/hilos/_hilo.json.jbuilder

json.extract! hilo, :id, :title, :content, :created_at, :updated_at, :boosts_count, :likes, :dislikes,
json.url hilo_url(hilo, format: :json)

# Agregar comentarios al JSON
# json.comments hilo.comments do |comment|
#   json.extract! comment, :hilo_id, :id, :parent_id, :content, :created_at, :updated_at
#   json.user_id comment.user_id
#   json.username comment.user.username
# end
#
## Usar la función auxiliar para renderizar comentarios con anidación
json.propietario do 
  json.id hilo.user.id
  json.username hilo.user.username
end

json.comments_count hilo.comments.count

if hilo.magazine
  json.magazine do
    json.extract! hilo.magazine, :id, :name, :title
  end
else
  json.magazine nil
end

if hilo.comments
  json.comments build_nested_comments(hilo.comments.where(parent_id: nil))
else
  json.comments build_nested_comments(hilo.comments.where(parent_id: nil))
end
