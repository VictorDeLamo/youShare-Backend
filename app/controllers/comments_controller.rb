class CommentsController < ApplicationController
  include CommentsHelper
  before_action :set_comment, only: [:destroy, :like, :dislike, :boost, :edit, :update]
  before_action :authenticate_user_api, only: [:manage_reaction, :create, :destroy, :like, :dislike, :boost, :edit, :update]

  def create
    logger.debug "Received params: #{params.inspect}"
    @hilo = Hilo.find_by(id: params[:hilo_id])
  unless @hilo
    respond_to do |format|
      format.html { redirect_to root_url, alert: 'Hilo not found.' }
      format.json { render json: { error: 'Hilo not found' }, status: :not_found }
    end
    return
  end
    #@hilo = Hilo.find(params[:hilo_id])
    @comment = @hilo.comments.build(comment_params)
    @comment.user = current_user

    # api_key = request.headers["ApiKey"]
    # user = User.find_by(api_key: api_key)

    #@comment.parent_id = params[:comment][:parent_id] if params[:comment][:parent_id].present?
    # Verifica si el parent_id está presente y es válido

    if params[:comment][:parent_id].present?
      parent_comment = Comment.find_by(id: params[:comment][:parent_id])
      unless parent_comment
        return render json: { error: "Parent comment does not exist." }, status: :bad_request
      end
    end

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @hilo, notice: 'Comment was successfully created.' }
        format.json { render json: { message: 'Comment was successfully created.', comment: @comment }, status: :created, location: [@hilo, @comment] }
      else
        logger.debug "Comment save errors: #{@comment.errors.full_messages}"
        format.html { redirect_to @hilo, alert: 'Comment could not be posted. Content NULL or maximum characters reached (1000)' }
        format.json { render json: {error: 'Content NULL or max characters reached (1000)!'}, status: :bad_request }
      end
    end
  end


  def new
    @hilo = Hilo.find(params[:hilo_id])
    @comment = Comment.new
    @comment.parent_id = params[:parent_id] if params[:parent_id].present?
    # No necesitas renderizar explícitamente new.html.erb, Rails lo hace automáticamente
  end

  def edit

  end

  def update
    api_key = request.headers["ApiKey"]
    user = User.find_by(api_key: api_key)

    if user.nil?
      render json: { error: "Invalid API Key" }, status: :unauthorized
    elsif @comment.user_id != user.id
      render json: { error: "You aren't the owner" }, status: :forbidden
    elsif params[:comment].key?(:parent_id)
      render json: { error: "parent_id cannot be changed" }, status: :bad_request
    else
      respond_to do |format|
        if @comment.update(comment_params.except(:parent_id)) # Ignora parent_id
          format.html { redirect_to hilo_path(@comment.hilo), notice: 'Comment was successfully updated.' }
          format.json { render json: { message: 'Comment was successfully updated.', comment: @comment }, status: :ok }
        else
          format.html { render :edit, alert: 'Could not update comment. Content NULL or max characters reached (1000)' }
          format.json { render json: { error: 'Content NULL or max characters reached (1000)' }, status: :bad_request }
        end
      end
    end
  end



  # def destroy
  #   @comment.destroy
  #   redirect_to hilo_path(@comment.hilo), notice: 'Comment was successfully deleted.'
  # end

  def destroy
    if request.headers["Accept"] == "application/json"
      api_key = request.headers["ApiKey"]
      user = User.find_by(api_key: api_key)

      if user.nil?
        return render json: { error: "Invalid API Key" }, status: :unauthorized
      end

      if @comment.user_id != user.id
        render json: { error: "You aren't the owner" }, status: :forbidden
      else
        @comment.destroy
        respond_to do |format|
          format.html { redirect_to hilo_path(@comment.hilo), notice: 'Comment was successfully deleted.' }
          format.json { render json: { message: 'Comment was successfully deleted' }, status: :ok }
        end
      end
    end
  end



  def like
    api_key = request.headers["ApiKey"]
    user = User.find_by(api_key: api_key)

    # if @comment.user_id != user.id
    #   render json: { error: "You aren't the owner" }, status: :forbidden
    # else
      existing_reaction = @comment.comment_reactions.find_by(user_id: user.id)

      if existing_reaction&.status == 'like'
        existing_reaction.destroy
        @comment.decrement!(:likes)
        @user_reaction = nil
        message = 'Like removed'
      else
        existing_reaction&.destroy if existing_reaction # elimina la reacción opuesta si existe
        @comment.comment_reactions.create(user_id: user.id, status: 'like')
        @comment.increment!(:likes)
        @comment.decrement!(:dislikes) if existing_reaction&.status == 'dislike'
        @user_reaction = 'like'
        message = 'Like added'
      end

      respond_to do |format|
        format.html { redirect_to request.referer || root_path, notice: message }
        format.json { render json: { message: message }, status: :ok }
      end
    # end
  end

  def dislike
    api_key = request.headers["ApiKey"]
    user = User.find_by(api_key: api_key)

    # if @comment.user_id != user.id
    #   render json: { error: "You aren't the owner" }, status: :forbidden
    # else
      existing_reaction = @comment.comment_reactions.find_by(user_id: user.id)

      if existing_reaction&.status == 'dislike'
        existing_reaction.destroy
        @comment.decrement!(:dislikes)
        @user_reaction = nil
        message = 'Dislike removed'
      else
        existing_reaction&.destroy if existing_reaction # elimina la reacción opuesta si existe
        @comment.comment_reactions.create(user_id: user.id, status: 'dislike')
        @comment.increment!(:dislikes)
        @comment.decrement!(:likes) if existing_reaction&.status == 'like'
        @user_reaction = 'dislike'
        message = 'Dislike added'
      end

      respond_to do |format|
        format.html { redirect_to request.referer || root_path, notice: message }
        format.json { render json: { message: message }, status: :ok }
      end
    # end
  end

  def boost
    api_key = request.headers["ApiKey"]
    user = User.find_by(api_key: api_key)

    # if @comment.user_id != user.id
    #   render json: { error: "You aren't the owner" }, status: :forbidden
    # else
      existing_boost = CommentBoost.find_by(comment_id: @comment.id, user_id: user.id)

      if existing_boost
        existing_boost.destroy
        message = 'Boost removed'
      else
        CommentBoost.create!(comment: @comment, user: user)
        message = 'Boost added'
      end

      respond_to do |format|
        format.html { redirect_to request.referer || root_path, notice: message }
        format.json { render json: { message: message }, status: :ok }
      end
    # end
  end

  private

def set_comment
  #if request.headers["Accept"] == "application/json"
  @hilo = Hilo.find_by(id: params[:hilo_id])
  unless @hilo
    respond_to do |format|
      format.html { redirect_to root_url, alert: 'Hilo not found.' }
      format.json { render json: { error: 'Hilo not found' }, status: :not_found }
    end
    return
  end

  @comment = @hilo.comments.find_by(id: params[:id])
  unless @comment
    respond_to do |format|
      format.html { redirect_to root_url, alert: 'Comment not found.' }
      format.json { render json: { error: 'Comment not found' }, status: :not_found }
    end
  end
end




  def check_user
    unless current_user == @comment.user
      redirect_to hilo_path(@comment.hilo), alert: 'You are not authorized to delete this comment.'
    end
  end




  private

  def comment_params
    # Permitir parent_id solo para crear
    if action_name == 'create'
      params.require(:comment).permit(:content, :parent_id)
    else
      params.require(:comment).permit(:content)
    end
  end

end
