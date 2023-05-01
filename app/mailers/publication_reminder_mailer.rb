class PublicationReminderMailer < ApplicationMailer
  def first_reminder(user_id, project_id)
    @user = User.find(user_id)
    @project = Project.find(project_id)
    mail(to: @user.email, subject: 'SRDRPlus Projects in need of your attention')
  end

  def second_reminder(user_id, project_id)
    @user = User.find(user_id)
    @project = Project.find(project_id)
    mail(to: @user.email, subject: 'SRDRPlus Projects in need of your attention')
  end
end