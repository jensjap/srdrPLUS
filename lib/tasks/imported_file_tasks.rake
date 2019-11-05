namespace :imported_files do
  task add_file_types: [:environment] do
    file_type_arr = [{ name: '.csv' }, { name: '.ris' }, { name: '.xlsx' }, { name: '.enl' }, { name: 'PubMed' }, { name: '.json' }]
    file_type_arr.each do |file_type_dict|
      FileType.find_or_create_by(file_type_dict)
    end
  end
  
  task add_import_types: [:environment] do
    import_type_arr = [{ name: 'Distiller References' }, { name: 'Distiller Section' }, { name: 'Citation' }, { name: 'Project' }]
    import_type_arr.each do |import_type_dict|
      ImportType.find_or_create_by(import_type_dict)
    end
  end
   
  task add_projects_user_references: [:environment] do
    ImportedFile.left_joins(:projects_user).where(imported_files: { projects_user_id: nil }).each do |imported_file|
      projects_user = ProjectsUser.find_by project: imported_file.project, user: imported_file.user
      if projects_user.present?
        puts "Adding projects_user_id=#{projects_user.id.to_s} to imported_file with id=#{imported_file.id.to_s}"
        imported_file.update projects_user: projects_user
      else
        puts "ERROR: imported_file with id=#{imported_file.id.to_s} has invalid references"
        input = nil
        while not ['Y','N'].include? input
          input = ask "Confirm Deletion (Y/N):"
        end
        if input == 'Y'
          imported_file.destroy          
        end
      end
    end
  end
end
