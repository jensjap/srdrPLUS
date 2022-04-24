namespace :project_tasks do
  desc "Template for creating tasks with arguments.

    Options:
      1. Copy project information, KQs, extraction form structure only.
      2. In addition to 1. also copy suggested Arms and Outcomes.
      3. In addition to 2. also copy extracted Arms and Outcomes and put in Suggested list.

    Use: rails project_tasks:copy_project[source_project_id, copy_options]"
  task :copy_project, [:arg_m, :arg_n] => [:environment] do |t, args|
    return unless args.arg_m.present?
    arg_n = args.arg_n || 1

    arg_m = args.arg_m.to_i
    arg_n = arg_n.to_i
    Rails.logger.info("Copy project with id #{ arg_m } and option #{ arg_n }")

    ActiveRecord::Base.transaction do
      src_project, dst_project = _copy_project(arg_m)
      return unless dst_project

      _copy_project_leaders(src_project, dst_project)
      return unless dst_project.leaders.present?

      _copy_key_questions(src_project, dst_project)

      src_efp = src_project.extraction_forms_projects.first
      dst_efp = dst_project.extraction_forms_projects.first
      _copy_extraction_forms_project_type(src_efp, dst_efp)
      _copy_extraction_forms_projects_sections(src_efp, dst_efp)
      _copy_type1_suggestions(src_efp, dst_efp) if arg_n >= 2
      _copy_questions_in_type2_sections(src_efp, dst_efp)
    end  # ActiveRecord::Base.transaction do
  end

  private

  def _copy_project(source_project_id)
    src_project = Project.find(source_project_id)
    dst_project_name = "Copy of Project ID: #{ src_project.id }"
    dst_project_name += ", Name: '#{ src_project.name }'"
    dst_project_name += ", Timestamp: #{ Time.now.strftime("%Y-%m-%d %H:%M:%S") }"
    dst_project                         = Project.new( name: dst_project_name)
    dst_project.description             = src_project.description
    dst_project.attribution             = src_project.attribution
    dst_project.methodology_description = src_project.methodology_description
    dst_project.prospero                = src_project.prospero
    dst_project.doi                     = src_project.doi
    dst_project.notes                   = src_project.notes
    dst_project.funding_source          = src_project.funding_source

    if dst_project.valid?
      dst_project.save
      Rails.logger.info("Create copy of project succeeded.")
      return src_project, dst_project
    else
      Rails.logger.warn("Create copy of project failed.")
      Rails.logger.warn("Errors: #{ dst_project.errors.full_messages.join(", ") }")
      return false
    end  # if dst_project.valid?
  end  # def _copy_project(source_project_id)

  def _copy_project_leaders(src_project, dst_project)
    Rails.logger.info("Add project leaders.")
    src_project.leaders.each do |user|
      dst_project.users << user
      ProjectsUser.find_by(project: dst_project, user: user).roles << Role.first
    end  # src_project.leaders.each do |user|

    # Add contributor for now to check.
    contributor = User.find(2)
    unless dst_project.users.include?(contributor)
      dst_project.users << contributor
      ProjectsUser.find_by(project: dst_project, user: contributor).roles << Role.first
    end

    unless dst_project.leaders.present?
      Rails.logger.warn("Destination project has no leaders. Abort copy")
    end  # unless dst_project.leaders.present?
  end  # def _copy_project_leaders(src_project, dst_project)

  def _copy_key_questions(src_project, dst_project)
    Rails.logger.info("Copying Key Questions.")
    src_project.key_questions_projects.each do |kqp|
      dst_project.key_questions_projects.create(
        key_question: kqp.key_question)
    end  # src_project.key_questions_projects.each do |kqp|
  end  # def _copy_key_questions(src_project, dst_project)

  def _copy_extraction_forms_project_type(src_efp, dst_efp)
    dst_efp.extraction_forms_project_type = src_efp.extraction_forms_project_type
    dst_efp.save
  end  # def _copy_extraction_forms_project_type(src_efp, dst_efp)

  def _copy_extraction_forms_projects_sections(src_efp, dst_efp)
    dst_efp.extraction_forms_projects_sections.destroy_all
    src_efp.extraction_forms_projects_sections.each do |efps|
      dst_efp.extraction_forms_projects_sections.create(
        extraction_forms_projects_section_type: efps.extraction_forms_projects_section_type,
        section: efps.section,
        link_to_type1: efps.link_to_type1,
        hidden: efps.hidden,
        helper_message: efps.helper_message)
    end  # src_efp.extraction_forms_projects_sections.each do |efps|
  end  # def _copy_extraction_forms_projects_sections(src_efp, dst_efp)

  def _copy_type1_suggestions(src_efp, dst_efp)
    src_efp.extraction_forms_projects_sections.where(extraction_forms_projects_section_type_id: 1).each do |efps|
      dst_efps = dst_efp
        .extraction_forms_projects_sections
        .where(extraction_forms_projects_section_type: efps.extraction_forms_projects_section_type,
               section: efps.section,
               link_to_type1: efps.link_to_type1,
               hidden: efps.hidden,
               helper_message: efps.helper_message)
        .first
      efps.extraction_forms_projects_sections_type1s.each do |efpst1|
        dst_efps.extraction_forms_projects_sections_type1s.create(
          type1: efpst1.type1,
          type1_type: efpst1.type1_type)
      end
    end  # src_efp.extraction_forms_projects_sections.where(extraction_forms_projects_section_type_id: 1).each do |efps|
  end  # def _copy_type1_suggestions(src_efp, dst_efp)

  def _copy_questions_in_type2_sections(src_efp, dst_efp)
    src_efp.extraction_forms_projects_sections.where(extraction_forms_projects_section_type_id: 2).each do |efps|
      dst_efps = dst_efp
        .extraction_forms_projects_sections
        .where(extraction_forms_projects_section_type: efps.extraction_forms_projects_section_type,
               section: efps.section,
               link_to_type1: efps.link_to_type1,
               hidden: efps.hidden,
               helper_message: efps.helper_message)
        .first
      efps.questions.each do |question|
        dst_question = dst_efps.questions.create(
          name: question.name,
          description: question.description)
        _fix_question_kq_associations(question, dst_question)
        _copy_question_structure(question, dst_question)
      end  # efps.questions.each do |question|
    end  # src_efp.extraction_forms_projects_sections.where(extraction_forms_projects_section_type_id: 2).each do |efps|
  end  # def _copy_questions_in_type2_sections(src_efp, dst_efp)

  def _fix_question_kq_associations(src_question, dst_question)
    dst_question.key_questions_projects.destroy_all
    src_question.key_questions_projects.each do |kqp|
      dst_kqp = dst_question.extraction_forms_project
        .project
        .key_questions_projects
        .joins(:key_question)
        .where(key_questions: { name: kqp.key_question.name })
        .first
      dst_question.key_questions_projects << dst_kqp
    end  # src_question.key_questions_projects.each do |kqp|
  end  # def _fix_question_kq_associations(src_question, dst_question)

  def _copy_question_structure(src_question, dst_question)
    _copy_question_rows(src_question, dst_question)
  end  # def _copy_question_structure(src_question, dst_question)

  def _copy_question_rows(src_question, dst_question)
    dst_question.question_rows.destroy_all
    src_question.question_rows.each do |qr|
      qr_copy = qr.amoeba_dup
      qr_copy.question_id = dst_question.id
      qr_copy.save
    end  # src_question.question_rows.each do |qr|
  end  # def _copy_question_rows(src_question, dst_question)
end  # task :copy_project, [:arg_m, :arg_n] => [:environment] do |t, args|
