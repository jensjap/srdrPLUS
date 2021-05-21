class ProjectPolicy < ApplicationPolicy
  FULL_PARAMS = [
    :citation_file,
    :name,
    :description,
    :attribution,
    :authors_of_report,
    :methodology_description,
    :prospero,
    :doi,
    :notes,
    :funding_source,
    {
      tasks_attributes: [
        :id,
        :name,
        :num_assigned,
        :task_type_id,
        projects_users_role_ids: []
      ]
    },
    {
      citations_attributes: [
        :id,
        :name,
        :abstract,
        :pmid,
        :refman,
        :citation_type_id,
        :page_number_start,
        :page_number_end,
        :_destroy,
        authors_citations_attributes: [
          { author_attributes: :name },
          { ordering_attributes: :position },
          :_destroy
        ],
        author_ids: [],
        keyword_ids: [],
        journal_attributes: [
          :id,
          :name,
          :volume,
          :issue,
          :publication_date
        ]
      ]
    },
    {
      citations_projects_attributes: [
        :id,
        :_destroy,
        :citation_id,
        :project_id,
        citation_attributes: [
          :id,
          :_destroy,
          :name
          ]
      ]
    },
    {
      key_questions_projects_attributes: [
        :id,
        :position
      ]
    },
    { key_questions_attributes: [:name] },
    {
      projects_users_attributes: [
        :id,
        :_destroy,
        :user_id,
        role_ids: [],
        imports_attributes: [
          :import_type_id, {
            imported_files_attributes: [
              :id,
              :file_type_id,
              :content,
              section: [:name],
              key_question: [:name]
            ]
          }
        ]
      ]
    },
    {
      screening_options_attributes: [
        :id,
        :_destroy,
        :project_id,
        :label_type_id,
        :screening_option_type_id
      ]
    }
  ]

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if Rails.env.test?
      scope.joins(:projects_users).where('projects_users.user_id = ?', user.id)
    end
  end

  def show?
    project_contributor? || @user.admin?
  end

  def edit?
    project_leader? || @user.admin?
  end

  def update?
    project_contributor?
  end

  def destroy?
    project_leader?
  end

  def export_to_gdrive?
    project_contributor?
  end

  def export?
    project_contributor? || @record.public?
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

  def next_assignment?
    project_contributor?
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
        { citations_projects_attributes: [:id, :citation_id] },
        { citations_attributes: [:id, :name, :abstract, :pmid, :refman, :citation_type_id, :page_number_start, :page_number_end, authors_citations_attributes: [{ author_attributes: :name }, { ordering_attributes: :position }], keyword_ids:[], journal_attributes: [ :id, :name, :volume, :issue, :publication_date]] }
      ]
    end
  end
end