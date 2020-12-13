class Api::V2::EvidenceVariablesController < Api::V2::BaseController
  before_action :set_evidence_variable, only: [:show]

  resource_description do
    short 'End-Points describing Outcome Definitions'
    formats [:json]
  end

  api :GET, '/v2/evidence_variables.json', 'Full list of Outcome definitions. Requires API Key.'
  param_group :paginate, Api::V2::BaseController
  returns desc: 'Index of Outcome Definitions; paginate (optional).' do
    property :is_paginated, :boolean, desc: 'Is response paginated or not.'
    property :page, Integer, desc: 'Page returned.'
    property :per_page, Integer, desc: 'Number of resources returned per page.'
    property :evidence_variables, array_of: Hash do
      property :id, Integer, desc: 'Resource ID.'
      property :url, String, desc: 'URL of resource.'
      property :name, String, desc: 'Resource name (human readable).'
    end
  end
  def index
    page     = params[:page]
    per_page = params[:per_page]
    evidence_variables_tmp = ExtractionsExtractionFormsProjectsSectionsType1
      .includes(:type1, extractions_extraction_forms_projects_sections_type1_rows:
                [extractions_extraction_forms_projects_sections_type1_row_columns: :timepoint_name
      ])
      .joins(extractions_extraction_forms_projects_section: [extraction_forms_projects_section: :section])
      .where('sections.name=?', "Outcomes")

    if page.present?
      @is_paginated = true
      @page = page.to_i
      if per_page.present?
        @per_page = per_page.to_i
        @evidence_variables = evidence_variables_tmp.page(@page).per(@per_page)
      else
        @per_page = 10
        @evidence_variables = evidence_variables_tmp.page(@page).per(@per_page)
      end
    else
      @evidence_variables = evidence_variables_tmp.all
    end
  end

  api :GET, '/v2/evidence_variables/:id.json', 'Individual Outcome Definition. FHIR formatted evidence variable. See http://build.fhir.org/evidencevariable.html for full description. Requires API Key.'
  param_group :resource_id, Api::V2::BaseController
  returns desc: 'FHIR formatted Outcome Definition.' do
    property :resourceType, String, desc: 'Resource type description.'
    property :id, Integer, desc: 'Resource ID.'
    property :meta, Hash do
      property :versionId, Integer, desc: 'Version ID.'
    end
    property :url_index, String, desc: 'URL where index is found.'
    property :url, String, desc: 'URL where indidvidual record is found.'
    property :name, String
    property :title, String
    property :status, String
    property :date, DateTime
    property :description, String
    property :characteristic, array_of: Hash do
      property :description, String
      property :definitionCodeableConcept, Hash do
        property :coding, array_of: Hash do
          property :system, String
          property :code, Integer
          property :display, String
        end
        property :exclude, :boolean
      end
      property :timeFromStart, Hash do
        property :quantity, Hash do
          property :value, String
          property :comparator, String
          property :unit, String
          property :system, String
          property :code, String
        end
      end
    end
  end
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
