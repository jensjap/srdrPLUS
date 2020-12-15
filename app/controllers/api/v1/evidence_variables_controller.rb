module Api
  module V1
    class EvidenceVariablesController < BaseController
      before_action :set_evidence_variable, only: [:show]

      resource_description do
        short 'Outcome Definitions'
        formats ['json']
        deprecated false
      end

      api :GET, '/v1/evidence_variables.json', 'Full list of Outcome definitions. Requires API Key.'
      def index
        @evidence_variables = ExtractionsExtractionFormsProjectsSectionsType1
          .includes(:type1, extractions_extraction_forms_projects_sections_type1_rows:
                    [extractions_extraction_forms_projects_sections_type1_row_columns: :timepoint_name
          ])
          .joins(extractions_extraction_forms_projects_section: [extraction_forms_projects_section: :section])
          .where('sections.name=?', "Outcomes")
          .all
        render 'index.json'
      end

      api :GET, '/v1/evidence_variables/:id.json', 'Individual Outcome Definition. FHIR formatted evidence variable. See http://build.fhir.org/evidencevariable.html for full description. Requires API Key.'
      def show
        @populations = @evidence_variable.extractions_extraction_forms_projects_sections_type1_rows
        pop = @populations.try(:last)
        tps = pop.try(:extractions_extraction_forms_projects_sections_type1_row_columns) if pop
        tp = tps.try(:last) if tps
        @timepoint_name = tp.present? ? tp.timepoint_name.name : ''
        @timepoint_unit = tp.present? ? tp.timepoint_name.unit : ''
      end

      private
        def set_evidence_variable
          @evidence_variable = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:id])
        end
    end
  end
end
