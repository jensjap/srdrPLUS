namespace :imports do
  task add_projects_user_references: [:environment] do
    ImportedFile.left_joins(:projects_user).where(imported_files: { projects_user_id: nil }).each do |imported_file|
      projects_user = ProjectsUser.find_by project: imported_file.project, user: imported_file.user
      if projects_user.present?
        puts "Adding projects_user_id=#{projects_user.id} to imported_file with id=#{imported_file.id}"
        imported_file.update projects_user:
      else
        puts "ERROR: imported_file with id=#{imported_file.id} has invalid references"
        input = nil
        input = ask 'Confirm Deletion (Y/N):' until %w[Y N].include? input
        imported_file.destroy if input == 'Y'
      end
    end
  end
end
