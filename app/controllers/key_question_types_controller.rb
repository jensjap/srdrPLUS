class KeyQuestionTypesController < ApplicationController
  DEFAULT_KEY_QUESTION_TYPES = [
    "Intervention benefits and/or harms",
    "Epidemiology - Exposure-outcome relationship",
    "Epidemiology - Incidence/prevalence",
    "Diagnostic accuracy"
  ].freeze

  def index
    if params[:q]
      @key_question_types = KeyQuestionType.by_query(params[:q])
    else
      @key_question_types = KeyQuestionType.where(name: DEFAULT_KEY_QUESTION_TYPES).uniq
    end
  end
end
