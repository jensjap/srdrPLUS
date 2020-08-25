module Api
  module V1
    class EvidenceVariablesController < BaseController
      before_action :set_evidence_variable, only: [:show]

      api :GET, '/v1/evidence_variables.json'
      formats [:json]
      def index
        @evidence_variables = ExtractionsExtractionFormsProjectsSectionsType1.all
        render 'index.json'
      end

      api :GET, '/v1/evidence_variables/:id.json'
      formats [:json]
      def show
        @populations = @evidence_variable.extractions_extraction_forms_projects_sections_type1_rows
        @timepoint_name = @populations.last.extractions_extraction_forms_projects_sections_type1_row_columns.last.timepoint_name.name
        @timepoint_unit = @populations.last.extractions_extraction_forms_projects_sections_type1_row_columns.last.timepoint_name.unit
      end

      private
        def set_evidence_variable
          @evidence_variable = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:id])
        end
    end
  end
end
