class Type1sController < ApplicationController
  before_action :set_extraction_forms_projects_section, only: [:new, :create]
  before_action :set_type1, only: [:edit, :update, :destroy]
  before_action :skip_policy_scope, :skip_authorization

  # GET /extraction_forms_projects_sections/1/type1s/new
  def new
    @type1 = @extraction_forms_projects_section.type1s.new
  end

  # GET /extraction_forms_projects_sections/1/type1s/edit
  def edit
  end

  # POST /extraction_forms_projects_section/1/type1s
  # POST /extraction_forms_projects_section/1/type1s.json
  def create
    @type1 = Type1.find_or_initialize_by(name: type1_params[:name], description: type1_params[:description])
    respond_to do |format|
      if @type1.save
        begin
          @extraction_forms_projects_section.type1s << @type1
        rescue ActiveRecord::RecordInvalid => e
          format.html { redirect_to build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                                        'panel-tab': @extraction_forms_projects_section.id),
                                                                        alert: e }
        end
        format.html { redirect_to build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                                      'panel-tab': @extraction_forms_projects_section.id),
                                                                      notice: t('success') }
        format.json { render :show, status: :created, location: @type1 }
      else
        format.html { redirect_to build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                                      'panel-tab': @extraction_forms_projects_section.id),
                                                                      alert: t('failure') }
        format.json { render json: @type1.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /type1s/1
  # PATCH/PUT /type1s/1.json
  def update
    respond_to do |format|
      if @type1.update(type1_params)
        format.html { redirect_to build_extraction_forms_project_path(@type1.extraction_forms_projects_section.extraction_forms_project,
                                                                      'panel-tab': @type1.extraction_forms_projects_section.id),
                                                                      notice: t('success') }
        format.json { render :show, status: :ok, location: @type1 }
      else
        format.html { render :edit }
        format.json { render json: @type1.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /type1s/1
  # DELETE /type1s/1.json
#  def destroy
#    @type1.destroy
#    respond_to do |format|
#      format.html { redirect_to build_extraction_forms_project_path(@type1.extraction_forms_projects_section.extraction_forms_project,
#                                                                    'panel-tab': @type1.extraction_forms_projects_section.id),
#                                                                    notice: t('removed') }
#      format.json { head :no_content }
#    end
#  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_extraction_forms_projects_section
    @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:extraction_forms_projects_section_id])
  end

  def set_type1
    @type1 = Type1.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def type1_params
    params.require(:type1).permit(:name, :description)
  end
end
