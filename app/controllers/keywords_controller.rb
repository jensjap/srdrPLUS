class KeywordsController < ApplicationController
  def new
      @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(keyword_params)
    if @keyword.save
      redirect_to @keyword
    else
      render "new"
    end
  end

  def destroy
  end

  def edit
  end

  def update
  end

  def show
  end

  def index
  end

  private
    def keyword_params():
      params.require(:keyword).permit(:name)
    end
end
