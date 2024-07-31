class MagazinesController < ApplicationController
  include MagazinesHelper
  before_action :set_magazine, only: %i[ show edit update destroy suscribir unsubscribe hilos]
  before_action :authenticate_user_api, only: [:new, :create, :suscribir, :unsuscribir, :edit, :destroy]
  # GET /magazines or /magazines.json
  def index
    sort_by = params[:sort] || "null"
    direction = params[:direction] || "null"
    case sort_by
    when "title"
      @magazines = Magazine.includes(:hilos).order("#{sort_by} #{direction}")
    when "hilos"
      if direction == "asc"
        @magazines = Magazine.all.sort_by { |magazine| [magazine.hilos.where(url: [nil, '']).count] }
      else
        @magazines = Magazine.all.sort_by { |magazine| [magazine.hilos.where(url: [nil, '']).count] }.reverse
      end
    when "publicaciones"
      if direction == "asc"
        @magazines = Magazine.all.sort_by { |magazine| [magazine.hilos.count] }
      else
        @magazines = Magazine.all.sort_by { |magazine| [magazine.hilos.count] }.reverse
      end
    when "suscriptores"
      if direction == "asc"
        @magazines = Magazine.all.sort_by { |magazine| [magazine.users.count] }
      else
        @magazines = Magazine.all.sort_by { |magazine| [magazine.users.count] }.reverse
      end
    when "comments"
      if direction == "asc"
        @magazines = Magazine.all.sort_by { |magazine| [total_comentarios_magazine(magazine)] }
      else
        @magazines = Magazine.all.sort_by { |magazine| [total_comentarios_magazine(magazine)] }.reverse
      end
    else
      @magazines = Magazine.all
    end
  end

  # GET /magazines/1 or /magazines/1.json
  def show
  end

  # GET /magazines/new
  def new
    @magazine = Magazine.new
  end

  # GET /magazines/1/edit
  def edit
  end

  # POST /magazines or /magazines.json
  def create
    @magazine = current_user.magazines.new(magazine_params)#Magazine.new(magazine_params)

    respond_to do |format|
      if @magazine.save
        format.html { redirect_to magazine_url(@magazine), notice: "Magazine was successfully created." }
        format.json { render :show, status: :created, location: @magazine }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @magazine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /magazines/1 or /magazines/1.json
  def update
    if request.headers["Accept"] == "application/json"
      api_key = request.headers["ApiKey"]
      user = User.find_by(api_key: api_key)
      
      if @magazine.user_id != user.id
        render json: { error: "You aren't the owner" }, status: :forbidden and return
      end
    end
      respond_to do |format|
        if @magazine.update(magazine_params)
          format.html { redirect_to magazine_url(@magazine), notice: "Magazine was successfully updated." }
          format.json { render :show, status: :ok, location: @magazine }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @magazine.errors, status: :unprocessable_entity }
        end
      end
    
  end

  # DELETE /magazines/1 or /magazines/1.json
  def destroy
    if request.headers["Accept"] == "application/json"
      api_key = request.headers["ApiKey"]
      user = User.find_by(api_key: api_key)
      
      if @magazine.user_id != user.id
        render json: { error: "You aren't the owner" }, status: :forbidden and return
      end
    end
      @magazine.destroy

      respond_to do |format|
        format.html { redirect_to magazines_url, notice: "Magazine was successfully destroyed." }
        format.json { render json: { message: "Magazine deleted" }, status: :ok }
      end    
  end

  #Post Suscribirse /magazines/:id/suscribir
  def suscribir
    @magazine = Magazine.find(params[:id])
    existing_subscription = Suscripcione.find_by(user_id: current_user.id, magazine_id: @magazine.id)
    
    if existing_subscription
      render json: { error: "You already follow it" }, status: :ok
    else
      Suscripcione.create(user_id: current_user.id, magazine_id: @magazine.id)
      if request.headers["Accept"] == "application/json"
        render json: { error: "You follow it" }, status: :ok
      else
        redirect_to magazines_path, notice: "Te has suscrito a #{@magazine.title}"
      end
    end
  
  end
  # delete Suscribirse /magazines/:id/unsubscribe
  def unsubscribe
    @magazine = Magazine.find(params[:id])
    if request.headers["Accept"] == "application/json"
      api_key = request.headers["ApiKey"]
      current_user = User.find_by(api_key: api_key)
    end
    suscripcion = Suscripcione.find_by(user_id: current_user.id, magazine_id: @magazine.id)
    
    if suscripcion.nil?
      render json: { error: "You don't follow it" }, status: :ok
    else
      suscripcion.destroy
      if request.headers["Accept"] == "application/json"
        render json: { error: "You don't follow it, now" }, status: :ok
      else
        redirect_to magazines_path, notice: "Te has desuscrito de #{@magazine.title}"
      end
    end
  end

  def hilos
    @hilos = Magazine.find(params[:id]).hilos
    render json: @hilos
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_magazine
      @magazine = Magazine.find_by_id(params[:id])
      if @magazine.nil?
        if request.method == "DELETE"
          render json: { error: "No content" }, status: :no_content
        else
          render json: { error: "Not found" }, status: :not_found
        end
      end
    end

    # Only allow a list of trusted parameters through.
    def magazine_params
      params.require(:magazine).permit(:name, :title, :description, :rules)
    end
end
