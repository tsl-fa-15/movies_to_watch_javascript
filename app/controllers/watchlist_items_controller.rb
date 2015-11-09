class WatchlistItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_watchlist_item, only: [:show, :edit, :update, :destroy, :check_if_owner, :unwatch]
  before_action :check_if_owner, only: [:show, :edit, :update, :destroy]

  def index
    @watchlist_items = WatchlistItem.all
    @watched_items = WatchlistItem.where(watched: true).order(updated_at: :asc)
    @unwatched_items = WatchlistItem.where(watched: false).order(updated_at: :asc)
  end

  def show
  end

  def new
    @watchlist_item = WatchlistItem.new
  end

  def create
    @watchlist_item = WatchlistItem.new(watchlist_item_params)

    if @watchlist_item.save
      respond_to do |format|
        format.html {redirect_to movies_url, :notice => "Watchlist item created successfully."}
        format.js {render 'create'}
      end
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @watchlist_item.update_attributes(watchlist_item_params)
      redirect_to watchlist_item_url(@watchlist_item.id), :notice => "Watchlist item updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @watchlist_item.destroy

    respond_to do |format|
      format.html {redirect_to :back, :notice => "Watchlist item deleted."}
      format.js {render 'destroy'}
    end
  end

  def watch
    watchlist_item = WatchlistItem.where(user_id: params[:user_id], movie_id: params[:movie_id]).first
    @watchlist_item = watchlist_item || WatchlistItem.new(user_id: params[:user_id], movie_id: params[:movie_id])
    @watchlist_item.watched = true



    if @watchlist_item.save
      if @watchlist_item.user.watched_movie_count == 3
        WatchlistMailer.novice_level_achieved(@watchlist_item.user).deliver_now
      end

      respond_to do |format|
        format.html { redirect_to movies_url, notice: "Movie marked as watched" }
        format.js
      end
    else
      redirect_to movies_url, notice: "There was an error marking your movie as watched"
    end
  end

  def unwatch
    @watchlist_item.watched = false
    @watchlist_item.save

    if @watchlist_item.save
      respond_to do |format|
        format.html {redirect_to movies_url, notice: "Movie marked as unwatched"}
        format.js
      end
    else
      redirect_to movies_url, notice: "There was an error marking your movie as unwatched"
    end
  end

  def set_watchlist_item
    @watchlist_item = WatchlistItem.find(params[:id])
  end

  def check_if_owner
    if current_user.id != @watchlist_item.user_id
      redirect_to root_url, notice: "You must be the owner to do that"
    end
  end

  def watchlist_item_params
    params.require(:watchlist_item).permit(:user_id, :movie_id, :watched)
  end
end
