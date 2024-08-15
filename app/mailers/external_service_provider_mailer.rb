class ExternalServiceProviderMailer < ApplicationMailer
  def notify_share_success(*args)
    @external_service_providers_projects_user = ExternalServiceProvidersProjectsUser.find(args.first)
    @project = Project.find(args.second)
    @user = User.find(args.third)
    @resource_url = args.fourth
    @lsof_fois = args.fifth
    mail(to: @user.email, subject: 'You have a notification from srdrPLUS')
  end

  def notify_share_failure(*args)
    @args = args
    @user = User.find(args.third)
    mail(to: @user.email, subject: 'You have a notification from srdrPLUS (share failure)')
  end
end
