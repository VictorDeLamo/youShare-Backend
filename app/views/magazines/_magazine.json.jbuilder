json.extract! magazine, :id, :name, :title, :description, :rules, :created_at, :updated_at
json.url magazine_url(magazine, format: :json)

json.hilos_count magazine.hilos.where(url: nil).count

json.comentarios_count total_comentarios_magazine(magazine)

json.publicaciones_count magazine.hilos.count

json.suscripciones_count magazine.suscripciones.count

json.propietario do 
    json.id magazine.user.id
    json.username magazine.user.username
end

json.hilos_ids  magazine.hilos.pluck(:id)
