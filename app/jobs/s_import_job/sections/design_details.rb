require 's_import_job/sections/worksheet_section'

#!!!
class DesignDetails < WorksheetSection

  protected

  #!!!
  def _validate_row(row)
    return true
  end

  #!!!
  def _process_row(row)
    pmid, assigned_user, author, pub_date, study_title, row = _extract_study_identifiers(row)

    @extraction = _find_extraction(pmid=pmid, assigned_user=assigned_user,
      author=author, pub_date=pub_date, study_title=study_title)

    @project = Project.find(@project_id)
    @efp = @project.extraction_forms_projects.first
    @efps = ExtractionFormsProjectsSection.find_or_create_by(
      extraction_forms_project: @efp,
      extraction_forms_projects_section_type: ExtractionFormsProjectsSectionType.find_by(name: ExtractionFormsProjectsSectionType::TYPE2),
      section: Section.find_or_create_by(name: @section_name),
      extraction_forms_projects_section_id: nil,
      hidden: false
    )
    @eefps = ExtractionsExtractionFormsProjectsSection.find_by(
      extraction: @extraction,
      extraction_forms_projects_section: @efps
    )

    # By this step we should have only { question: value } pairs left in row ARRAY.
    row.each do |key, value|
      question = _process_question(key, value)
    end
  end

  #!!!
  def _return_worksheet_type
    return 'worksheet type'
  end

  private
    def _extract_study_identifiers(row)
      pmid          = row.delete('pmid')
      assigned_user = row.delete('assigned_user')
      author        = row.delete('author')
      pub_date      = row.delete('publicationdate')
      study_title   = row.delete('studytitle')
      refman        = row.delete('refman')
      included      = row.delete('included')
      citation_id   = row.delete('citationid')

      return pmid, assigned_user, author, pub_date, study_title, row
    end

    def _find_extraction(pmid, assigned_user, author, pub_date, study_title)
      citation = _find_citation(pmid, author, pub_date, study_title)
      project = Project.find @project_id
      citations_project = CitationsProject.find_or_create_by(citation: citation, project: project)
      projects_user = ProjectsUser.find(@projects_user_id)
      extraction = Extraction.find_or_create_by(
        project: project,
        citations_project: citations_project,
        projects_users_role: ProjectsUsersRole.find_or_create_by(
          projects_user_id: @projects_user_id,
          role: Role.find_by(name: Role::CONTRIBUTOR)
        )
      )

      return extraction
    end

    def _find_citation(pmid, author, pub_date, study_title)
      citation = nil

      if pmid
        citation = Citation.find_by(pmid: pmid)

      elsif author && pub_date && study_title
        author = Author.find_by(name: author)
        citation = Citation.where(name: study_title).where(authors: author)

      end  # END if pmid

      if citation.nil?
        citation = Citation.create(
          citation_type: CitationType.find_by(name: CitationType::PRIMARY),
          name: study_title,
          pmid: pmid
        )
      end  # END if citation.nil?

      return citation
    end

    def _process_question(question_text, question_value)
      question = _find_existing_question(question_text)
      eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by(
        extractions_extraction_forms_projects_sections_type1_id: nil,
        extractions_extraction_forms_projects_section_id: @eefps.id,
        question_row_column_field_id: question.question_row_column_fields.first.id
      )
      record = _find_record(eefps_qrcf)
      record.write_attribute(:name, question_value)
      record.save
    end

    def _find_record(eefps_qrcf)
      record = eefps_qrcf.records.first
      if record
        return record

      else
        return eefps_qrcf.records.build

      end  # END if record
    end

    def _find_existing_question(question_text)
      questions = @efps.questions.where(name: question_text)
      if questions.present?
        question = questions.first

      else
        question = Question.find_or_create_by!(name: question_text, extraction_forms_projects_section: @efps)

      end  # END if questions.present?

      @project.key_questions_projects.each do |kqp|
        question.key_questions_projects << kqp unless question.key_questions_projects.include? kqp
      end

      return question
    end
end
