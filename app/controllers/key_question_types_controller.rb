class KeyQuestionTypesController < ApplicationController
  DEFAULT_KEY_QUESTION_TYPES = [
    'Intervention benefits and/or harms',
    'Epidemiology - Exposure-outcome relationship',
    'Epidemiology - Incidence/prevalence',
    'Diagnostic accuracy',
    'Screening benefits and/or harms'
  ].freeze

  def index
    @key_question_types = KeyQuestionType.by_query_and_page(params[:q], params[:page])
  end
end
