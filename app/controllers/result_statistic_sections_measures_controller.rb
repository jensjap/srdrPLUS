class ResultStatisticSectionsMeasuresController < ApplicationController
  def create
    rssm = ResultStatisticSectionsMeasure.new(result_statistic_section_id: params[:result_statistic_section_id],
                                              measure_id: params[:measure_id])
    authorize(rssm)
    rssm.save!
    respond_to do |format|
      format.json do
        render json: {}, status: 200
      end
    end
  end
end
