class ModelPerformancesController < ApplicationController
  ### If production, uncomment ###
  before_action :set_project, only: :show_by_project
  before_action :set_ml_model, only: :show_by_timestamp

  def show_by_project
    # render json: fake_data # for test without ml server

    ### If production, uncomment below and comment above ###
    ml_models_performances = @project.ml_models.order(:timestamp).map do |ml_model|
      performances = ml_model.model_performances.group_by(&:label).transform_values do |v|
        v.map(&:score)
      end

      {
        timestamp: ml_model.timestamp,
        performances: performances,
        confusion_matrix: ml_model.confusion_matrix,
        precision: ml_model.precision,
        recall: ml_model.recall,
        f1_score: ml_model.f1_score,
        accuracy_score: ml_model.accuracy_score
      }
    end

    ml_models_performances.sort_by! { |m| -m[:timestamp].to_i }
    render json: ml_models_performances
  end

  def show_by_timestamp
    # timestamp = params[:timestamp]
    # all_fake_data = fake_data
    # data_for_timestamp = all_fake_data.find { |data| data[:timestamp] == timestamp }

    # render json: data_for_timestamp || { error: 'Model not found for this timestamp' }

    ### If production, uncomment below and comment above ###
    performances = @ml_model.model_performances.group_by(&:label).transform_values do |v|
      v.map(&:score)
    end

    render json: {
      performances:,
      confusion_matrix: @ml_model.confusion_matrix,
      precision: @ml_model.precision,
      recall: @ml_model.recall,
      f1_score: @ml_model.f1_score,
      accuracy_score: @ml_model.accuracy_score
    }
  end

  def show_timestamps
    # render json: fake_timestamps # for test without ml server

    ### If production, uncomment below and comment above ###
    project_id = params[:project_id]
    timestamps = MlModel.joins(:projects).where("projects.id = ?", project_id).pluck(:timestamp)

    render json: { timestamps: timestamps }
  end

  private

  def set_project
    project_id = params[:project_id]
    @project = Project.find(project_id)

    render json: { error: 'Project not found' }, status: :not_found if @project.nil?
  end

  def set_ml_model
    if params[:timestamp]
      timestamp = params[:timestamp]
      @ml_model = MlModel.find_by(timestamp:)
    end

    render json: { error: 'Model not found' }, status: :not_found if @ml_model.nil?
  end

  def fake_data
    timestamps = %w[
      20230517104819
      20230517105932
      20230525082200
      20230525083151
      20230525083314
      20230525084827
      20230525084854
      20230526023153
    ]

    ml_models_performances = timestamps.map do |timestamp|
      performances = { '0' => Array.new(50) { rand(0.0..0.5) }, '1' => Array.new(50) { rand(0.5..1.0) } }
      confusion_matrix = { TP: 25, TN: 25, FP: 25, FN: 0 }
      precision = 0.5
      recall = nil
      f1_score = 0.5
      accuracy_score = 0.5

      {
        timestamp:,
        performances:,
        confusion_matrix:,
        precision:,
        recall:,
        f1_score:,
        accuracy_score:
      }
    end

    ml_models_performances.sort_by { |m| -m[:timestamp].to_i }
  end

  def fake_timestamps
    {
      timestamps: %w[
        20230517104819
        20230517105932
        20230525082200
        20230525083151
        20230525083314
        20230525084827
        20230525084854
        20230526023153
      ]
    }
  end
end
