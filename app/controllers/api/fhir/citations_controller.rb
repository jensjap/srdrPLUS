class Api::Fhir::CitationsController < ApplicationController
  # TODO check exist view and implement search parms logic
  # TODO use fhir_models gem to validate and save into FhirCitation model

  def index
    raise NotImplementedError
  end

  def show
    raise NotImplementedError
  end

  def new
    raise NotImplementedError
  end

  def edit
    raise NotImplementedError
  end

  def create
    raise NotImplementedError
  end

  def update
    raise NotImplementedError
  end

  def destroy
    raise NotImplementedError
  end

  private

    def citation_params
      # TODO check exist params, ask :_destroy
    end

end
