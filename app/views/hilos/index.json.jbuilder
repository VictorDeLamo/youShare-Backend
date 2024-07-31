# app/views/hilos/index.json.jbuilder
json.array! @hilos do |hilo|
  json.extract! hilo, :id, :title, :content, :url, :likes, :dislikes, :created_at, :updated_at, :boosts_count

  if hilo.magazine
    json.magazine do
      json.extract! hilo.magazine, :id, :name, :title
    end
  else
    json.magazine nil
  end
  json.propietario do 
    json.id hilo.user.id
    json.username hilo.user.username
  end
  json.comments_count hilo.comments.count
end

