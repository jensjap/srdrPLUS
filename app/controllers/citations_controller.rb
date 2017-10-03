class CitationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_citation, only: [:show, :edit, :update, :destroy]

  def new
      @citation = Citation.new
      @citation.authors.new
      @citation.build_journal
      @citation.keywords.new
  end

  def create
    @citation = Citation.new(citation_params)
    respond_to do |format|
      if @citation.save
        format.html { redirect_to edit_citation_path(@citation), notice: t('success') }
        format.json { render :show, status: :created, location: @citation }
      else
        format.html { render :new }
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @citation.update(citation_params)
        format.html { redirect_to @citation, notice: 'Citation was successfully updated.' }
        format.json { render :show, status: :ok, location: @citation }
      else
        format.html { render :edit }
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def destroy
    @citation.destroy
    respond_to do |format|
      format.html { redirect_to citations_url, notice: t('removed') }
      format.json { head :no_content }
     end
  end

  def show
  end

  private
    #a helper method that sets the current citation from id to be used with callbacks
    def set_citation
      @citation = Citation.includes(:projects)
                          .includes(:journals)
                          .includes(:keywords)
                          .find(params[:id])
    end

    def citation_params
      params.require(:citation)
          .permit(:name, :citation_type_id, :pmid, :refman, :abstract, 
          { journal_attributes: [:id, :name, :publication_date, :issue, :volume, :_destroy] },
          { authors_attributes: [:id, :name, :_destroy] },
            keywords_attributes: [:id, :name, :_destroy])
    end
end
