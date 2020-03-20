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
      @key_question_types = []
      @key_question_types << KeyQuestionType.find_or_create_by(name: DEFAULT_KEY_QUESTION_TYPES[0])
      @key_question_types << KeyQuestionType.find_or_create_by(name: DEFAULT_KEY_QUESTION_TYPES[1])
      @key_question_types << KeyQuestionType.find_or_create_by(name: DEFAULT_KEY_QUESTION_TYPES[2])
      @key_question_types << KeyQuestionType.find_or_create_by(name: DEFAULT_KEY_QUESTION_TYPES[3])
    end
  end
end
