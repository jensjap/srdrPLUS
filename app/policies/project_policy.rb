class ProjectPolicy < ApplicationPolicy
  FULL_PARAMS = [
    :notes,
    :citation_file,
    :name,
    :description,
    :attribution,
    :authors_of_report,
    :methodology_description,
    :prospero,
    :doi,
    :funding_source,
    {
      mesh_descriptor_ids: []
    },
    {
      citations_attributes: [
        :id,
        :name,
        :authors,
        :abstract,
        :accession_number,
        :registry_number,
        :doi,
        :other,
        :pmid,
        :refman,
        :citation_type_id,
        :page_number_start,
        :page_number_end,
        :_destroy,
        { keyword_ids: [],
          journal_attributes: %i[
            id
            name
            volume
            issue
            publication_date
          ] }
      ]
    },
    {
      citations_projects_attributes: [
        :id,
        :_destroy,
        :citation_id,
        :project_id,
        { citation_attributes: %i[
          id
          _destroy
          name
        ] }
      ]
    },
    { key_questions_attributes: [:name] },
    {
      projects_users_attributes: [
        :id,
        :_destroy,
        :user_id,
        :permissions,
        :is_expert,
        { imports_attributes: [
          :import_type_id, {
            imported_files_attributes: [
              :id,
              :file_type_id,
              :content,
              { section: [:name],
                key_question: [:name] }
            ]
          }
        ] }
      ]
    }
  ]

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if Rails.env.test?

      if user.admin?
        scope.all
      else
        scope.joins(:projects_users).where('projects_users.user_id = ?', user.id)
      end
    end
  end

  def show?
    project_auditor? || @user.admin?
  end

  def edit?
    project_auditor? || @user.admin?
  end

  def update?
    project_leader?
  end

  def destroy?
    project_leader?
  end

  def export_to_gdrive?
    project_auditor?
  end

  def export?
    project_auditor? || @record.public?
  end

  def export_data?
    project_auditor? || @record.public?
  end

  def export_assignments_and_mappings?
    project_leader?
  end

  def import_assignments_and_mappings?
    project_leader?
  end

  def simple_import?
    project_leader?
  end

  def import_csv?
    project_leader?
  end

  def import_pubmed?
    project_leader?
  end

  def import_ris?
    project_leader?
  end

  def import_endnote?
    project_leader?
  end

  def dedupe_citations?
    project_leader?
  end

  def create_citation_screening_extraction_form?
    project_leader?
  end

  def create_full_text_screening_extraction_form?
    project_leader?
  end

  def assign_extraction_to_any_user?
    project_leader?
  end

  def permitted_attributes
    if project_leader?
      FULL_PARAMS
    elsif project_contributor?
      [
        { projects_users_attributes: %i[id user_id permissions] },
        { citations_projects_attributes: %i[id citation_id] },
        { citations_attributes: [:id, :name, :authors, :abstract, :accession_number, :pmid, :refman, :registry_number, :doi,
                                 :other, :citation_type_id, :page_number_start, :page_number_end, { keyword_ids: [], journal_attributes: %i[id name volume issue publication_date] }] }
      ]
    end
  end
end
