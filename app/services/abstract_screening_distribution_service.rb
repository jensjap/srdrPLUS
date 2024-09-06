class AbstractScreeningDistributionService
  def initialize(abstract_screening)
    @abstract_screening = abstract_screening
    @users = determine_users
    @expert_users, @non_expert_users = classify_users_by_expertise
    @assigned_citations = calculate_assigned_citations

    @last_assigned_user = find_last_assigned_user(@users)
    @last_assigned_expert_user = find_last_assigned_user(@expert_users)
    @last_assigned_non_expert_user = find_last_assigned_user(@non_expert_users)

    @second_last_assigned_user = find_second_last_assigned_user(@users, @last_assigned_user)

    @random_user = determine_users.sample
  end

  def calculate_distributions
    delete_old_distributions

    citations_projects_to_allocate.each do |citations_project|
      allocate_citations_project(citations_project)
    end
  end

  def self.update_labeled_status(abstract_screening_result, user, labeled_status)
    distribution = AbstractScreeningDistribution.find_by(
      abstract_screening: abstract_screening_result.abstract_screening,
      citations_project: abstract_screening_result.citations_project,
      user: user
    )

    if distribution
      distribution.update(labeled: labeled_status)
    else
      raise ActiveRecord::RecordNotFound, "AbstractScreeningDistribution not found for the given criteria"
    end
  end

  private

  def classify_users_by_expertise
    expert_users = []
    non_expert_users = []

    @users.each do |user|
      if user.projects_users.find_by(project: @abstract_screening.project).is_expert
        expert_users << user
      else
        non_expert_users << user
      end
    end

    [expert_users, non_expert_users]
  end

  def find_last_assigned_user(user_group)
    last_result = @abstract_screening.citations_projects
                                     .joins(:abstract_screening_results)
                                     .where(abstract_screening_results: { user_id: user_group.map(&:id) })
                                     .order('abstract_screening_results.created_at DESC')
                                     .limit(1)
                                     .first

    last_result ? last_result.abstract_screening_results.first.user : nil
  end

  def find_second_last_assigned_user(user_group, last_assigned_user)
    second_last_result = @abstract_screening.citations_projects
                                            .joins(:abstract_screening_results)
                                            .where(abstract_screening_results: { user_id: user_group.map(&:id) })
                                            .where.not(abstract_screening_results: { user_id: last_assigned_user&.id })
                                            .order('abstract_screening_results.created_at DESC')
                                            .limit(1)
                                            .first

    second_last_result ? second_last_result.abstract_screening_results.first.user : nil
  end

  def last_another_user_excluding(excluded_users)
    last_result = @abstract_screening.citations_projects
                                     .joins(:abstract_screening_results)
                                     .where.not(abstract_screening_results: { user_id: excluded_users.map(&:id) })
                                     .order('abstract_screening_results.created_at DESC')
                                     .limit(1)
                                     .first

    last_result ? last_result.abstract_screening_results.first.user : random_user_excluding(excluded_users)
  end

  def delete_old_distributions
    @abstract_screening.abstract_screening_distributions.destroy_all
  end

  def citations_projects_without_asr
    @abstract_screening.citations_projects.where(screening_status: ["asu", "asps"]).select do |cp|
      cp.abstract_screening_results.empty?
    end
  end

  def citations_projects_to_allocate
    @abstract_screening.citations_projects.where(screening_status: ["asu", "asps"])
  end

  def determine_users
    if @abstract_screening.users.any?
      @abstract_screening.users
    else
      @abstract_screening.project.users
    end
  end

  def calculate_assigned_citations
    assigned_citations = Hash.new { |hash, key| hash[key] = [] }

    @abstract_screening.citations_projects.where(screening_status: "asps").each do |cp|
      cp.abstract_screening_results.each do |result|
        assigned_citations[result.user_id] << cp.id
      end
    end

    assigned_citations
  end

  def allocate_citations_project(citations_project)
    case @abstract_screening.abstract_screening_type
    when "single"
      allocate_single(citations_project)
    when "double", "expert-needed", "only-expert-novice-mixed"
      allocate_double(citations_project)
    when "pilot"
      allocate_pilot(citations_project)
    end
  end

  def allocate_single(citations_project)
    if citations_projects_to_allocate.size < 5
      assign_to_last_user(citations_project)
    else
      user = least_assigned_user
      create_distribution(citations_project, user)
    end
  end

  def allocate_double(citations_project)
    current_assignments = @assigned_citations.values.flatten.count(citations_project.id)

    if current_assignments >= 2
      return
    end

    assigned_users = find_assigned_users(citations_project)

    if citations_projects_without_asr.size < 5
      if @abstract_screening.abstract_screening_type == "double"
        handle_double_type_assignments(current_assignments, assigned_users, citations_project)
      elsif @abstract_screening.abstract_screening_type == "expert-needed"
        handle_expert_needed_type_assignments(current_assignments, assigned_users, citations_project)
      elsif @abstract_screening.abstract_screening_type == "only-expert-novice-mixed"
        handle_only_expert_novice_mixed_assignments(current_assignments, assigned_users, citations_project)
      end
    else
      users_to_assign = case @abstract_screening.abstract_screening_type
                        when "double"
                          if current_assignments == 1
                            [least_assigned_user_excluding(assigned_users)]
                          else
                            [least_assigned_user, second_least_assigned_user]
                          end
                        when "expert-needed"
                          if current_assignments == 1
                            assigned_user_is_expert = assigned_users.any? { |user| user_is_expert?(user) }
                            assigned_user_is_expert ? [another_user_excluding(assigned_users)] : [expert_user]
                          else
                            [expert_user, another_user]
                          end
                        when "only-expert-novice-mixed"
                          if current_assignments == 1
                            assigned_user_is_expert = assigned_users.any? { |user| user_is_expert?(user) }
                            assigned_user_is_expert ? [non_expert_user] : [expert_user]
                          else
                            [expert_user, non_expert_user]
                          end
                        end

      users_to_assign.each { |user| create_distribution(citations_project, user) }
    end
  end

  def allocate_pilot(citations_project)
    @users.each do |user|
      create_distribution(citations_project, user) unless already_assigned?(citations_project, user)
    end
  end

  def create_distribution(citations_project, user)
    latest_ml_prediction = citations_project.ml_predictions.order(created_at: :desc).first
    ml_score = latest_ml_prediction ? latest_ml_prediction.score : nil

    AbstractScreeningDistribution.create!(
      abstract_screening: @abstract_screening,
      citations_project: citations_project,
      user: user,
      ml_score: ml_score
    )

    @assigned_citations[user.id] << citations_project.id
  end

  def handle_double_type_assignments(current_assignments, assigned_users, citations_project)
    if current_assignments == 1
      user = find_user_for_double_type_single_assignment(assigned_users)
      create_distribution(citations_project, user)
    else
      users_to_assign = find_users_for_double_type_remaining_assignments(assigned_users)
      users_to_assign.each { |user| create_distribution(citations_project, user) }
    end
  end

  def find_user_for_double_type_single_assignment(assigned_users)
    @last_assigned_user && !assigned_users.include?(@last_assigned_user) ? @last_assigned_user : random_user_excluding(assigned_users)
  end

  def find_users_for_double_type_remaining_assignments(assigned_users)
    user1 = @last_assigned_user || random_user_excluding(assigned_users)
    user2 = @second_last_assigned_user || random_user_excluding(assigned_users + [user1])
    [user1, user2]
  end

  def handle_expert_needed_type_assignments(current_assignments, assigned_users, citations_project)
    if current_assignments == 1
      if assigned_users.any? { |user| user_is_expert?(user) }
        user = last_another_user_excluding(assigned_users)
      else
        user = @last_assigned_expert_user || expert_user
      end
      create_distribution(citations_project, user)
    else
      user1 = @last_assigned_expert_user || expert_user
      user2 = last_another_user_excluding([user1])
      create_distribution(citations_project, user1)
      create_distribution(citations_project, user2)
    end
  end

  def handle_only_expert_novice_mixed_assignments(current_assignments, assigned_users, citations_project)
    if current_assignments == 1
      if assigned_users.any? { |user| user_is_expert?(user) }
        user = @last_assigned_non_expert_user || non_expert_user
      else
        user = @last_assigned_expert_user || expert_user
      end
      create_distribution(citations_project, user)
    else
      user1 = @last_assigned_non_expert_user || non_expert_user
      user2 = @last_assigned_expert_user || expert_user
      create_distribution(citations_project, user1)
      create_distribution(citations_project, user2)
    end
  end

  def find_assigned_users(citations_project)
    @users.select { |user| @assigned_citations[user.id].include?(citations_project.id) }
  end

  def user_is_expert?(user)
    @expert_users.include?(user)
  end

  def least_assigned_user_excluding(excluded_users)
    (@users - excluded_users).min_by { |user| @assigned_citations[user.id].size }
  end

  def least_assigned_user
    @users.min_by { |user| @assigned_citations[user.id].size }
  end

  def second_least_assigned_user
    (@users - [least_assigned_user]).min_by { |user| @assigned_citations[user.id].size }
  end

  def expert_user
    @expert_users.min_by { |user| @assigned_citations[user.id].size }
  end

  def non_expert_user
    @non_expert_users.min_by { |user| @assigned_citations[user.id].size }
  end

  def another_user_excluding(excluded_users)
    least_assigned_user_excluding(excluded_users)
  end

  def random_user_excluding(excluded_users)
    (@users - excluded_users).sample
  end

  def already_assigned?(citations_project, user)
    @assigned_citations[user.id].include?(citations_project.id)
  end

  def assign_to_last_user(citations_project)
    user = @last_assigned_user || @random_user
    create_distribution(citations_project, user)
  end
end
