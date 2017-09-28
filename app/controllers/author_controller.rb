class AuthorController < ApplicationController
  def new
      @author = Author.new
  end

  def create
      @author = Author.new(author_params)
      if @author.save
        redirect_to @author
      else
        render "new"
      end
  end

  def index
  end

  def show
  end

  def edit
  end

  def destroy
  end
  
  private
    def author_params():
      params.require(:author).permit(:name)
    end
end
