class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  before_action :require_admin, only: [:destroy]

  def index
    @users = User.paginate(page: params[:page], per_page: 6)
  end

  def show
    @user_articles = @user.articles.paginate(page: params[:page], per_page: 5)
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Welcome to the Alpha Blog #{ @user.username }"
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Your account was updated successfully"
      redirect_to articles_path
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:danger] = "The user and all his articles have been deleted"
    redirect_to users_path
  end

  private
  def user_params
    params.require(:user).permit(:username, :email, :password)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def require_same_user
    if !logged_in? || ( current_user != @user && !current_user.admin? )
      flash[:danger] = "You can only edit your own account"
      redirect_to root_path
    end
  end

  def require_admin
    if logged_in? && !current_user.admin?
      flash[:danger] = "Only admin can perform that action"
      redirect_to root_path
    end
  end
end
