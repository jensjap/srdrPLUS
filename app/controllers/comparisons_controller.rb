class ComparisonsController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization

  def create
    @comparison = Comparison.new(comparison_params)
    @result_statistic_section = ResultStatisticSection.find(@comparison.result_statistic_section_id)

    respond_to do |format|
      if @comparison.save
        format.html { redirect_to edit_result_statistic_section_path(@result_statistic_section), notice: t('success') }
        format.json { render :show, status: :created, location: @comparison }
      else
        format.html { render :new }
        format.json { render json: @comparison.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def comparison_params
    params.require(:comparison).permit(:result_statistic_section_id)
  end
end
