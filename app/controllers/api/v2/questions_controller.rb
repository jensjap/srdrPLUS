class Api::V2::QuestionsController < Api::V2::BaseController
  before_action :set_question, only: [:show]

  resource_description do
    short 'End-Points describing Question definitions. Questions are part of a section within an Extraction Form.'
    formats [:json]
  end

  def_param_group :cell_desc do
    property :id, Integer, desc: 'Resource ID.'
    property :header_name, String
  end

  def_param_group :question do
    property :id, Integer, desc: 'Resource ID.'
    property :key_questions, Hash do
      param_group :key_question, Api::V2::KeyQuestionsController
    end
    property :name, String
    property :instructions, String
    property :url, String
    property :question_structure, Hash do
      property :rows, Hash do
        param_group :cell_desc, Api::V2::QuestionsController
      end
      property :columns, Hash do
        param_group :cell_desc, Api::V2::QuestionsController
      end
      property :cells, Hash do
        property :id, Integer, desc: 'Resource ID.'
        property :row, Hash do
          param_group :cell_desc, Api::V2::QuestionsController
        end
        property :cell, Hash do
          param_group :cell_desc, Api::V2::QuestionsController
        end
        property :question_type, String
        property :answer_options, Hash do
          property :option, String
        end
      end
    end
  end

  api :GET, '/v2/questions/:id.json', 'Display complete question definition. Requires API Key.'
  param_group :resource_id, Api::V2::BaseController
  def show
    authorize(@question.project, policy_class: QuestionPolicy)
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end
end