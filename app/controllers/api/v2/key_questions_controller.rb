class Api::V2::KeyQuestionsController < Api::V2::BaseController
  before_action :set_key_question, only: [:show]

  resource_description do
    short 'End-Points describe Key Questions.'
    formats [:json]
  end

  def_param_group :key_question do
    property :id, Integer, desc: 'Resource ID.'
    property :name, String
    property :created_at, DateTime
    property :updated_at, DateTime
    property :url, String
  end

  api :GET, '/v2/key_questions/:id.json'
  param_group :resource_id, Api::V2::BaseController
  def show; end

  private

  def set_key_question
    @key_question = KeyQuestion.find(params[:id])
  end
end
