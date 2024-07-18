class ExternalServiceProvidersProjectsUserShareJob < ApplicationJob
  queue_as :exports

  rescue_from(StandardError) do |exception|
    Sentry.capture_exception(exception) if Rails.env.production?
    debugger if Rails.env.development?
    ExternalServiceProviderMailer.notify_share_failure(*arguments).deliver_later
  end

  def perform(*args)
    return if args.any?(&:blank?)

    @external_service_providers_projects_user = ExternalServiceProvidersProjectsUser.find(args.first)
    @project = Project.find(args.second)
    @user = User.find(args.third)
    fps = FevirPlatformService.new(@project.id, @external_service_providers_projects_user.api_token)
    response = fps.submit_resource
    if response['success']
      lsof_fois = response['fois']
      resource_url = "#{@external_service_providers_projects_user.external_service_provider.url}"
      ExternalServiceProviderMailer.notify_share_success(*args, resource_url, lsof_fois).deliver_later
    else
      ExternalServiceProviderMailer.notify_share_failure(*args, response).deliver_later
    end
  end
end
