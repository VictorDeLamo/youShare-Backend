class HilosController < ApplicationController
  before_action :authenticate_user_api, only: [:create, :like, :dislike, :destroy, :edit, :boost, :update]
  before_action :set_hilo, only: %i[ show edit update destroy like dislike boost]
  before_action :authenticate_user, only: [:update, :destroy]
  before_action :check_hilo_ownership, only: [:update, :destroy]
  helper_method :clean_params

  # GET /hilos or /hilos.json
  def index
    @hilos = Hilo.includes(:user, :magazine).all
    @hilos = filter_hilos(@hilos, params[:filter])
    @hilos = order_hilos(@hilos, params[:order])
    logger.debug "Ordenados Hilos: " + @hilos.as_json(only: [:id, :title, :likes, :dislikes]).map(&:inspect).join(", ")

    # Verifica si hay un usuario autenticado antes de intentar acceder a current_user.id
    if current_user
      user_reactions = Reaction.where(hilo_id: @hilos.pluck(:id), user_id: current_user.id).pluck(:hilo_id, :status).to_h
      @user_reactions = user_reactions
    else
      @user_reactions = {}
    end
  end


  # GET /hilos/1 or /hilos/1.json
  class HilosController < ApplicationController
    def show
      @hilo = Hilo.includes(:user, :magazine).find_by(id: params[:id])
      @comments = @hilo.comments.includes(:user) # Asume que cada comentario pertenece a un usuario
      @top_level_comments = @comments.where(parent_id: nil)
      # Para hilos:
      @user_reactions = current_user ? Reaction.where(hilo_id: @hilo.id, user_id: current_user.id).pluck(:hilo_id, :status).to_h : {}
      # Para comentarios:
      @comment_reactions = current_user ? CommentReaction.where(comment_id: @comments.pluck(:id), user_id: current_user.id).pluck(:comment_id, :status).to_h : {}
      @new_comment = Comment.new
    end
  end


# GET /hilos/new
def new
  @form_type = params[:type] # Esto almacena el tipo de formulario que quieres mostrar
  @hilo = Hilo.new         # Esto crea siempre una instancia de Hilo, no importa el tipo
end

  # GET /hilos/1/edit
  def edit
    # `set_hilo` ya debería estar obteniendo el objeto correcto.
    # Asegúrate de que `@hilo_type` se establece si es necesario para la vista.
    @hilo_type = @hilo.class.name.downcase
  end


  # POST /hilos or /hilos.json
  def create
    @hilo = current_user.hilos.new(hilo_params)

    respond_to do |format|
      if @hilo.save
        session[:created_ids] = (session[:created_ids] || []) << @hilo.id
        format.html { redirect_to root_path }
        format.json { render :show, status: :created, location: @hilo }
      else
        format.html { render :new, notice: 'Unable to save hilo.' }
        format.json { render json: @hilo.errors, status: :unprocessable_entity }
      end
    end
  end



  # PATCH/PUT /hilos/1 or /hilos/1.json
  def update
    respond_to do |format|
      if @hilo.update(hilo_params)
        format.html { redirect_to hilo_url(@hilo), notice: "Hilo was successfully updated." }
        format.json { render :show, status: :ok, location: @hilo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @hilo.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /hilos/1 or /hilos/1.json
  def destroy
    @hilo.destroy
    respond_to do |format|
      format.html { redirect_to hilos_url, notice: "Hilo was successfully destroyed." }
      format.json { head :no_content }
    end
  end

    #Like hilos
    def like

      existing_reaction = Reaction.find_by(hilo_id: @hilo.id, user_id: current_user.id)

      if existing_reaction
        if existing_reaction.status == 'like'
          existing_reaction.destroy
          @hilo.decrement!(:likes)
          @user_reaction = nil
        else
          existing_reaction.update(status: 'like')
          @hilo.increment!(:likes)
          @hilo.decrement!(:dislikes)
          @user_reaction = 'like'
        end
      else
        Reaction.create(hilo_id: @hilo.id, user_id: current_user.id, status: 'like')
        @hilo.increment!(:likes)
        @user_reaction = 'like'
      end

      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.json { render json: {likes: @hilo.likes, dislikes: @hilo.dislikes }, status: :ok }
      end
    end

    # Método dislike actualizado
    def dislike

      existing_reaction = Reaction.find_by(hilo_id: @hilo.id, user_id: current_user.id)

      if existing_reaction
        if existing_reaction.status == 'dislike'
          existing_reaction.destroy
          @hilo.decrement!(:dislikes)
          @user_reaction = nil
        else
          existing_reaction.update(status: 'dislike')
          @hilo.increment!(:dislikes)
          @hilo.decrement!(:likes)
          @user_reaction = 'dislike'
        end
      else
        Reaction.create(hilo_id: @hilo.id, user_id: current_user.id, status: 'dislike')
        @hilo.increment!(:dislikes)
        @user_reaction = 'dislike'
      end

      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.json { render json: {likes: @hilo.likes, dislikes: @hilo.dislikes }, status: :ok }
      end
    end

    def boost

      existing_boost = Boost.find_by(hilo_id: @hilo.id, user_id: current_user.id)

      if existing_boost
        existing_boost.destroy
      else
        Boost.create!(hilo: @hilo, user: current_user)
      end


      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.json { render json: { likes: @hilo.likes, dislikes: @hilo.dislikes, boosts: @hilo.boosts.count }, status: :ok }
      end
    end

    private

    def set_hilo
      @hilo = Hilo.find_by(id: params[:id])
      unless @hilo
        respond_to do |format|
          format.html { redirect_to hilos_url, alert: "Hilo not found" }
          format.json { render json: { error: "Hilo not found" }, status: :not_found }
        end
        return
      end
    end

    def authenticate_user
      @user = request.headers["Accept"] == "application/json" ? User.find_by(api_key: request.headers["ApiKey"]) : current_user
      if @user.nil?
        respond_to do |format|
          format.html { redirect_to hilos_url, alert: "You need to be logged in to perform this action" }
          format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
        end
      end
    end

    def check_hilo_ownership
      if @hilo.user_id != @user.id
        respond_to do |format|
          format.html { redirect_to hilos_url, alert: "You aren't the owner" }
          format.json { render json: { error: "Forbidden" }, status: :forbidden }
        end
        return
      end
    end


    def hilo_params
      params.require(:hilo).permit(:title, :content, :url, :magazine_id)
    end


    def filter_hilos(hilos, filter)
      case filter
      when 'links'
        hilos.where.not(url: [nil, ''])  # Filtra solo hilos con URL no nula y no vacía
      when 'hilos'
        hilos.where(url: [nil, ''])  # Filtra solo hilos sin URL o con URL vacía
      else
        hilos  # No aplica ningún filtro, muestra todos los hilos
      end
    end

    def order_hilos(hilos, order_param)
      case order_param
      when 'top'
        hilos.order(Arel.sql('likes - dislikes DESC'))
      when 'newest'
        hilos.order(created_at: :desc)
      when 'commented'
        hilos.left_joins(:comments).group(:id).order('COUNT(comments.hilo_id) DESC')
      else
        hilos
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

    def clean_params
      params.permit(:order, :filter, :comments_order)
    end


  end
