class DataAnalysisLevelsController < ApplicationController
  DEFAULT_DATA_ANALYSIS_LEVELS = [
    "Individual participant data (IPD)",
    "Summary"
  ].freeze

  def index
    if params[:q]
      @data_analysis_levels =  DataAnalysisLevel.by_query(params[:q])
    else
      @data_analysis_levels = []
      @data_analysis_levels << DataAnalysisLevel.find_or_create_by(name: DEFAULT_DATA_ANALYSIS_LEVELS[0])
      @data_analysis_levels << DataAnalysisLevel.find_or_create_by(name: DEFAULT_DATA_ANALYSIS_LEVELS[1])
    end
  end
end
