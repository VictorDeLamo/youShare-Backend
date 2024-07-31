class SearchController < ApplicationController
  def index
    if request.headers["Accept"] == "application/json"
      query = params[:query].to_s.downcase
      @hilos = Hilo.where('lower(title) LIKE ? OR lower(content) LIKE ?', "%#{query}%", "%#{query}%")

      respond_to do |format|
        format.html
        format.json do
          if query.present?
            render json: @hilos.map { |hilo| hilo_json(hilo) }
          else
            @hilos = Hilo.all
            render json: @hilos.map { |hilo| hilo_json(hilo) } , status: :ok
          end
        end
      end
    else
      @hilos = Hilo.all
    end
    
    
  end

  def hilo_json(hilo)
  {
        id: hilo.id,
        title: hilo.title,
        content: hilo.content,
        url: hilo.url,
        created_at: hilo.created_at,
        updated_at: hilo.updated_at,
        likes: hilo.likes,
        dislikes: hilo.dislikes,
        boosts_count: hilo.boosts_count,
        magazine: {
          id: hilo.magazine.id,
          name: hilo.magazine.name,
          title: hilo.magazine.title
        },
        propietario: {
          id: hilo.user.id,
          username: hilo.user.username
        },
        comments_count: hilo.comments.count
  }
  end

  
end
