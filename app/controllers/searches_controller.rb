class SearchesController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization, only: [:new, :create]
  skip_before_action :authenticate_user!, only: [:new, :create]
  skip_before_action :verify_authenticity_token, only: [:create]
#  before_action :set_search, only: [:show, :edit, :update, :destroy]

  # GET /searches/new
  def new
    @results = params[:results].to_json if params[:results].present?
  end

  # POST /searches
  # POST /searches.json
  def create
    @results = Hash.new
    @results[:raw_search_results] = Hash.new
    @results[:project_ids]  = Set.new
    @results[:citation_ids] = Set.new
    @search = search_params

    # Determine whether we are searching for Project or Citation.
    if @search[:projects_search].present?
      # Public project parameter is actually unnecessary since we should not search unpublished projects.
      is_public = ActiveModel::Type::Boolean.new.cast(@search[:projects_search].delete :public)
      is_owned  = ActiveModel::Type::Boolean.new.cast(@search[:projects_search].delete :owned)

      # Project name.
      @project_name_search_argument = @search[:projects_search][:name]
      @project_name_search_argument = @project_name_search_argument.present? ? @project_name_search_argument : '*'
      @project_name_search_result = Project.search(@project_name_search_argument,
                                                   fields: [:name],
                                                   track: { user_id: (current_user.present? ? current_user.id : 0) })
      @results[:raw_search_results][:by_project_name] = @project_name_search_result if @project_name_search_result.present?

      # Project description.
      @project_description_search_argument = @search[:projects_search][:description]
      if @project_description_search_argument.present?
        @project_description_search_result = Project.search(@project_description_search_argument,
                                                            fields: [:description],
                                                            track: { user_id: (current_user.present? ? current_user.id : 0) })
        @results[:raw_search_results][:by_project_description] = @project_description_search_result if @project_description_search_result.present?
      end

      # Project attribution.
      @project_attribution_search_argument = @search[:projects_search][:attribution]
      if @project_attribution_search_argument.present?
        @project_attribution_search_result = Project.search(@project_attribution_search_argument,
                                                            fields: [:attribution],
                                                            track: { user_id: (current_user.present? ? current_user.id : 0) })
        @results[:raw_search_results][:by_project_attribution] = @project_attribution_search_result if @project_attribution_search_result.present?
      end

      # Project methodology description.
      @project_methodology_description_search_argument = @search[:projects_search][:methodology_description]
      if @project_methodology_description_search_argument.present?
        @project_methodology_description_search_result = Project.search(@project_methodology_description_search_argument,
                                                                        fields: [:methodology_description],
                                                                        track: { user_id: (current_user.present? ? current_user.id : 0) })
        @results[:raw_search_results][:by_project_methodology_description] = @project_methodology_description_search_result if @project_methodology_description_search_result.present?
      end

      # Project prospero.
      @project_prospero_search_argument = @search[:projects_search][:prospero]
      if @project_prospero_search_argument.present?
        @project_prospero_search_result = Project.search(@project_prospero_search_argument,
                                                         fields: [:prospero],
                                                         track: { user_id: (current_user.present? ? current_user.id : 0) })
        @results[:raw_search_results][:by_project_prospero] = @project_prospero_search_result if @project_prospero_search_result.present?
      end

      # Project DOI.
      @project_doi_search_argument = @search[:projects_search][:doi]
      if @project_doi_search_argument.present?
        @project_doi_search_result = Project.search(@project_doi_search_argument,
                                                    fields: [:doi],
                                                    track: { user_id: (current_user.present? ? current_user.id : 0) })
        @results[:raw_search_results][:by_project_doi] = @project_doi_search_result if @project_doi_search_result.present?
      end

      # Project notes.
      @project_notes_search_argument = @search[:projects_search][:notes]
      if @project_notes_search_argument.present?
        @project_notes_search_result = Project.search(@project_notes_search_argument,
                                                      fields: [:notes],
                                                      track: { user_id: (current_user.present? ? current_user.id : 0) })
        @results[:raw_search_results][:by_project_notes] = @project_notes_search_result if @project_notes_search_result.present?
      end

      # Project funding source.
      @project_funding_source_search_argument = @search[:projects_search][:funding_source]
      if @project_funding_source_search_argument.present?
        @project_funding_source_search_result = Project.search(@project_funding_source_search_argument,
                                                               fields: [:funding_source],
                                                               track: { user_id: (current_user.present? ? current_user.id : 0) })
        @results[:raw_search_results][:by_project_funding_source] = @project_funding_source_search_result if @project_funding_source_search_result.present?
      end

      # Go through each raw search result and extract the project ids. Use merge here to get the union.
      @results[:raw_search_results].values.each do |val|
        @results[:project_ids].merge(val.map(&:id))
      end

      # Check conditions that would further reduce @results[:project_ids]
      # Project owned.
      if is_owned
        leading_project_ids = Project
          .joins(projects_users: [:user, { projects_users_roles: :role }])
          .where(projects_users: { user: current_user })
          .where(projects_users: { projects_users_roles: { roles: { name: 'Leader' } } })
        @results[:project_ids] = @results[:project_ids].present? ?
          @results[:project_ids] & leading_project_ids.map(&:id) :
          leading_project_ids.map(&:id)

      # If we are not restricting to projects we own, then we must only return projects that are published.
      else
        @results[:project_ids] = Project.published.where(id: @results[:project_ids].to_a).map{|p| p.id}
      end

      # Project members.
      @project_members_search_argument = @search[:projects_search][:members].downcase.split(' ')
      if @project_members_search_argument.present?
        new_project_ids = []
        restrict_to_user_ids = @project_members_search_argument.map { |username| User.joins(:profile).where(users: { profiles: { username: username } }).map(&:id) }

        @results[:project_ids].each do |project_id|
          Project.find(project_id).members.each do |member|
            if restrict_to_user_ids.flatten.include? member.id
              new_project_ids << project_id
              break
            end
          end
        end

        @results[:project_ids] = new_project_ids.to_set
      end

      # Project after date created.
      datestring = ''
      if @search[:projects_search]['after(1i)'].present? && @search[:projects_search]['after(1i)'].present? && @search[:projects_search]['after(1i)'].present?
        datestring = "#{ @search[:projects_search]['after(1i)'] }-#{ @search[:projects_search]['after(2i)'] }-#{ @search[:projects_search]['after(3i)'] }"
      end
      @project_after_search_argument = datestring.to_date
      if @project_after_search_argument.present?
        new_project_ids = []

        @results[:project_ids].each do |project_id|
          project = Project.find(project_id)
          if @project_after_search_argument < project.created_at
            new_project_ids << project.id
            next
          end
        end

        @results[:project_ids] = new_project_ids.to_set
      end

      # Project before date created.
      datestring = ''
      if @search[:projects_search]['before(1i)'].present? && @search[:projects_search]['before(1i)'].present? && @search[:projects_search]['before(1i)'].present?
        datestring = "#{ @search[:projects_search]['before(1i)'] }-#{ @search[:projects_search]['before(2i)'] }-#{ @search[:projects_search]['before(3i)'] }"
      end
      @project_before_search_argument = datestring.to_date
      if @project_before_search_argument.present?
        new_project_ids = []

        @results[:project_ids].each do |project_id|
          project = Project.find(project_id)
          if project.created_at < @project_before_search_argument
            new_project_ids << project.id
            next
          end
        end

        @results[:project_ids] = new_project_ids.to_set
      end

      # Project includes arm.
      @project_arm_search_argument = @search[:projects_search][:arm].downcase.split(' ')
      if @project_arm_search_argument.present?
        new_project_ids = []

        @project_arm_search_argument.each do |arm_name|
          arms = Type1.where(name: arm_name)
          arms.each do |arm|
            arm.extractions_extraction_forms_projects_sections.each do |eefps|
              project_id = eefps.extraction.project.id
              if @results[:project_ids].include? project_id
                new_project_ids << project_id
                next
              end
            end
          end
        end

        @results[:project_ids] = new_project_ids.to_set
      end

      # Project includes outcome.
      @project_outcome_search_argument = @search[:projects_search][:outcome].downcase.split(' ')
      if @project_outcome_search_argument.present?
        new_project_ids = []

        @project_outcome_search_argument.each do |outcome_name|
          outcomes = Type1.where(name: outcome_name)
          outcomes.each do |outcome|
            outcome.extractions_extraction_forms_projects_sections.each do |eefps|
              project_id = eefps.extraction.project.id
              if @results[:project_ids].include? project_id
                new_project_ids << project_id
                next
              end
            end
          end
        end

        @results[:project_ids] = new_project_ids.to_set
      end

    elsif @search[:citations_search].present?
      # Public project parameter is actually unnecessary since we should not search unpublished projects.
      is_public    = ActiveModel::Type::Boolean.new.cast(@search[:citations_search].delete :public)
      is_owned     = ActiveModel::Type::Boolean.new.cast(@search[:citations_search].delete :owned)
      is_restrict  = ActiveModel::Type::Boolean.new.cast(@search[:citations_search].delete :restrict)

      # Citation name.
      @citation_name_search_argument = @search[:citations_search][:name]
      @citation_name_search_argument = @citation_name_search_argument.present? ? @citation_name_search_argument : '*'
      @citation_name_search_result = Citation.search(@citation_name_search_argument,
                                                     fields: [:name],
                                                     track: { user_id: (current_user.present? ? current_user.id : 0) })
      @results[:raw_search_results][:by_citation_name] = @citation_name_search_result if @citation_name_search_result.present?

      # Citation RefMan.
      @citation_refman_search_argument = @search[:citations_search][:refman]
      if @citation_refman_search_argument.present?
        @citation_refman_search_result = Citation.search(@citation_refman_search_argument,
                                                         fields: [:refman],
                                                         track: { user_id: (current_user.present? ? current_user.id : 0) })
        @results[:raw_search_results][:by_citation_refman] = @citation_refman_search_result if @citation_refman_search_result.present?
      end

      # Citation PMID.
      @citation_pmid_search_argument = @search[:citations_search][:pmid]
      if @citation_pmid_search_argument.present?
        @citation_pmid_search_result = Citation.search(@citation_pmid_search_argument,
                                                       fields: [:pmid],
                                                       track: { user_id: (current_user.present? ? current_user.id : 0) })
        @results[:raw_search_results][:by_citation_pmid] = @citation_pmid_search_result if @citation_pmid_search_result.present?
      end

      # Citation abstract.
      @citation_abstract_search_argument = @search[:citations_search][:abstract]
      if @citation_abstract_search_argument.present?
        @citation_abstract_search_result = Citation.search(@citation_abstract_search_argument,
                                                           fields: [:abstract],
                                                           track: { user_id: (current_user.present? ? current_user.id : 0) })
        @results[:raw_search_results][:by_citation_abstract] = @citation_abstract_search_result if @citation_abstract_search_result.present?
      end

      # Go through each raw search result and extract the project ids. Use merge here to get the union.
      @results[:raw_search_results].values.each do |val|
        @results[:citation_ids].merge(val.map(&:id))
      end

      # Find all projects associated with the citations.
      @results[:project_ids].merge(CitationsProject.where(citation_id: @results[:citation_ids]).map { |cp| cp.project_id })

      # Check conditions that would further reduce @results[:project_ids]
      # Project owned.
      if is_owned
        leading_project_ids = Project
          .joins(projects_users: [:user, { projects_users_roles: :role }])
          .where(projects_users: { user: current_user })
          .where(projects_users: { projects_users_roles: { roles: { name: 'Leader' } } })
        @results[:project_ids] = @results[:project_ids].present? ?
          @results[:project_ids] & leading_project_ids.map(&:id) :
          leading_project_ids.map(&:id)

        # If we are not restricting to projects we own, then we must only return projects that are published.
      else
        @results[:project_ids] = Project.published.where(id: @results[:project_ids].to_a).map{ |p| p.id }
      end

      # Project members.
      @project_members_search_argument = @search[:citations_search][:members].downcase.split(' ')
      if @project_members_search_argument.present?
        new_project_ids = []
        restrict_to_user_ids = @project_members_search_argument.map { |username| User.joins(:profile).where(users: { profiles: { username: username } }).map(&:id) }

        @results[:project_ids].each do |project_id|
          Project.find(project_id).members.each do |member|
            if restrict_to_user_ids.flatten.include? member.id
              new_project_ids << project_id
              break
            end
          end
        end

        @results[:project_ids] = new_project_ids.to_set
      end

      # Project after date created.
      datestring = ''
      if @search[:citations_search]['after(1i)'].present? && @search[:citations_search]['after(1i)'].present? && @search[:citations_search]['after(1i)'].present?
        datestring = "#{ @search[:citations_search]['after(1i)'] }-#{ @search[:citations_search]['after(2i)'] }-#{ @search[:citations_search]['after(3i)'] }"
      end
      @project_after_search_argument = datestring.to_date
      if @project_after_search_argument.present?
        new_project_ids = []

        @results[:project_ids].each do |project_id|
          project = Project.find(project_id)
          if @project_after_search_argument < project.created_at
            new_project_ids << project.id
            next
          end
        end

        @results[:project_ids] = new_project_ids.to_set
      end

      # Project before date created.
      datestring = ''
      if @search[:citations_search]['before(1i)'].present? && @search[:citations_search]['before(1i)'].present? && @search[:citations_search]['before(1i)'].present?
        datestring = "#{ @search[:citations_search]['before(1i)'] }-#{ @search[:citations_search]['before(2i)'] }-#{ @search[:citations_search]['before(3i)'] }"
      end
      @project_before_search_argument = datestring.to_date
      if @project_before_search_argument.present?
        new_project_ids = []

        @results[:project_ids].each do |project_id|
          project = Project.find(project_id)
          if project.created_at < @project_before_search_argument
            new_project_ids << project.id
            next
          end
        end

        @results[:project_ids] = new_project_ids.to_set
      end

      # Project includes arm.
      @project_arm_search_argument = @search[:citations_search][:arm].downcase.split(' ')
      if @project_arm_search_argument.present?
        new_project_ids = []

        @project_arm_search_argument.each do |arm_name|
          arms = Type1.where(name: arm_name)
          arms.each do |arm|
            arm.extractions_extraction_forms_projects_sections.each do |eefps|
              project_id = eefps.extraction.project.id
              if @results[:project_ids].include? project_id
                new_project_ids << project_id
                next
              end
            end
          end
        end

        @results[:project_ids] = new_project_ids.to_set
      end

      # Project includes outcome.
      @project_outcome_search_argument = @search[:citations_search][:outcome].downcase.split(' ')
      if @project_outcome_search_argument.present?
        new_project_ids = []

        @project_outcome_search_argument.each do |outcome_name|
          outcomes = Type1.where(name: outcome_name)
          outcomes.each do |outcome|
            outcome.extractions_extraction_forms_projects_sections.each do |eefps|
              project_id = eefps.extraction.project.id
              if @results[:project_ids].include? project_id
                new_project_ids << project_id
                next
              end
            end
          end
        end
      end

    else
      raise RuntimeError, 'SearchesController::create - Neither searching projects nor citations.'

    end  # elsif @search[:citations_search].present?
  end

  private
#    # Use callbacks to share common setup or constraints between actions.
#    def set_search
#    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params
        .require(:searches)
        .permit(projects_search:
                [:public,
                 :owned,
                 :name,
                 :description,
                 :attribution,
                 :methodology_description,
                 :prospero,
                 :doi,
                 :notes,
                 :funding_source,
                 :members,
                 :after,
                 :before,
                 :arm,
                 :outcome],
                citations_search:
                [:public,
                 :owned,
                 :restrict,
                 :restrict_text,
                 :name,
                 :refman,
                 :pmid,
                 :abstract,
                 :members,
                 :answer_text,
                 :after,
                 :before,
                 :journal,
                 :arm,
                 :outcome,
                 :complete,
                 :measure,
                 :section_design_details,
                 :section_arm_details,
                 :section_sample_characteristics,
                 :section_outcome_details,
                 :section_quality])
    end
end
