class JournalController < ApplicationController
  def new
    @journal = Journal.new
  end

  def create
    @journal = Journal.new(journal_params)
    if @journal.save
      redirect_to @journal
    else
      render "new"
    end
  end

  def edit
  end

  def update
  end

  def show
  end

  def index
  end

  def destroy
  end

  private
    def journal_params():
        params.reqire(:journal).permit(:name, :publication_date, :issue, :volume)
end
