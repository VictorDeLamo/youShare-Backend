class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update generarApiKey boosts]
  before_action :authenticate_user_api, only: [:update, :generarApiKey, :boosts]
  before_action :check_user_ownership, only: [:update, :edit, :boosts]
  def show
    @comments = @user.comments
    @comment_reactions = current_user ? CommentReaction.where(comment_id: @comments.pluck(:id), user_id: current_user.id).pluck(:comment_id, :status).to_h : {}
    respond_to do |format|
      format.html
      format.json do
        begin
          render json: user_json(@user)
        end
      end
    end
  end
  def hilos
    @hilos = User.find(params[:id]).hilos
    render json: @hilos.map { |hilo| hilo_json(hilo) }
  end
  def comments
    @comments = User.find(params[:id]).comments
    render json: @comments.map { |comment| comment_json(comment) }
  end
  def boosts
    @boosts = User.find(params[:id]).boosts
    render json: @boosts.map { |boost| hilo_json(Hilo.find(boost.hilo_id)) }
  end
  def edit
  end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json do
          begin
            render json: user_json(@user)
          end
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  def generarApiKey
    codigo = hash_con_random_iteraciones(SecureRandom.hex(10))
    @user.update(api_key: codigo)
    respond_to do |format|
      format.html { redirect_to @user, notice: "ApiKey generated: #{codigo}" }
      format.json { render json: { api_key: codigo }, status: :ok }
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    unless @user
      respond_to do |format|
        format.html { redirect_to user_url, alert: "User not found" }
        format.json { render json: { error: "User not found" }, status: :not_found }
      end
      return
    end
  end

  def user_params
    if request.method == 'PUT'
      params.require(:user).permit(:username, :email, :description, :cover, :avatar)
    else
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :description, :cover, :avatar)

    end
  end
  def hash_con_random_iteraciones(string)
    iteraciones = rand(1..10)
    hash_resultado = Digest::SHA256.hexdigest(string)
    iteraciones.times do
      hash_resultado = Digest::SHA256.hexdigest(hash_resultado)
    end
    return hash_resultado
  end
  def user_json(user)
    {
      id: user.id,
      username: user.username,
      email: user.email,
      description: user.description,
      cover_url: user.cover.attached? ? url_for(user.cover) : nil,
      avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil,
      created_at: user.created_at,
      updated_at: user.updated_at
  }
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
  def comment_json(comment)
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
    replies: comment.replies.map { |reply| comment_json(reply) }
  }
  end
  def check_user_ownership
    if request.headers["Accept"] == "application/json"
      api_key = request.headers["ApiKey"]
      user = User.find_by(api_key: api_key)
      if @user.id != user.id
        respond_to do |format|
          format.html { redirect_to users_url, alert: "You aren't the owner" }
          format.json { render json: { error: "Forbidden" }, status: :forbidden }
        end
      end
    end
  end
end
