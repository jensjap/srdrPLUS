require  'csv'
require  'json'

desc "switch rails logger to stdout"
task :verbose => [:environment] do
  Rails.logger = Logger.new(STDOUT)
end

desc "find pmids and put them in a file"
task :find_pmids do
  abs_connection = ActiveRecord::Base.establish_connection(
    :adapter  => "mysql2",
    :host     => "localhost",
    :username => "root",
    :password => "",
    :database => "dummy"
  ).connection

  old_citations = []
  abs_connection.exec_query('SELECT title, authors, publication_date FROM citations').rows.each do |row|
    old_citations << row[0] + " " + row[1]
  end

  File.open(Rails.root.join("lib", "tasks", "temp", "terms.txt"), "w+") do |f|
    f.puts(old_citations)
  end

  system("python " + Rails.root.join("lib", "tasks", "helpers", "find_pmids.py").to_s + " " + Rails.root.join("lib", "tasks", "temp", "terms.txt").to_s + " " + Rails.root.join("lib", "tasks", "temp", "pmids.csv").to_s)
end

desc 'copy abstrackr data from old server'
task :populate_db do
  # connect to Abstrackr
  abs_connection = ActiveRecord::Base.establish_connection(
    :adapter  => "mysql2",
    :host     => "localhost",
    :username => "root",
    :password => "",
    :database => "dummy"
  ).connection

  #old_labels = abs_connection.exec_query('SELECT * FROM labels').to_hash
  old_users = abs_connection.exec_query('SELECT * FROM user').to_hash
  old_projects = abs_connection.exec_query('SELECT * FROM projects').to_hash
  old_citations = abs_connection.exec_query('SELECT * FROM citations').to_hash
  old_labels = abs_connection.exec_query('SELECT * FROM labels').to_hash
  old_tasks = abs_connection.exec_query('SELECT * FROM tasks').to_hash
  old_assignments = abs_connection.exec_query('SELECT * FROM assignments').to_hash
  old_users_projects = abs_connection.exec_query('SELECT * FROM users_projects').to_hash
  old_projects_leaders = abs_connection.exec_query('SELECT * FROM projects_leaders').to_hash
  old_notes = abs_connection.exec_query('SELECT * FROM notes').to_hash
  old_tags = abs_connection.exec_query('SELECT * FROM tags').to_hash

  # connect to srdrPLUS
  srdr_connection = ActiveRecord::Base.establish_connection(
    :adapter  => "mysql2",
    :host     => "localhost",
    :username => "root",
    :password => "",
    :database => "srdrPLUS_development"
  ).connection
  
  user_dict = {}
  old_users.each do |old_u|
    user = User.find_by(email: old_u['email'])
    if user.nil?
      user = User.new({email: old_u['email'], password:'password'})
      user.skip_confirmation!
      user.save
      user.profile.update({ username: old_u['username'], first_name: old_u['fullname'] })
    end
    user_dict[ old_u['id'] ] = user.id
  end

  project_dict = {}
  old_projects.each do |old_p|
    project = Project.create!({ name: old_p['name'], description: old_p['description'] })
    project_dict[ old_p['id'] ] = project.id
  end

  old_users_projects.each do |old_u_p|
    projects_user_id = ProjectsUser.find_or_create_by!({ project_id: project_dict[old_u_p['project_id']], user_id: user_dict[old_u_p['user_id']] }).id
    ProjectsUsersRole.create!({ projects_user_id: projects_user_id, role_id: 2 })
  end

  old_projects_leaders.each do |old_p_l|
    projects_user_id = ProjectsUser.find_or_create_by!({ project_id: project_dict[old_p_l['project_id']], user_id: user_dict[old_p_l['user_id']] }).id
    projects_users_role = ProjectsUsersRole.find_by!({ projects_user_id: projects_user_id })
    if projects_users_role.nil?
      projects_users_role = ProjectsUsersRoles.create!({ projects_user_id: projects_user_id, role_id: 1 })
    end
    projects_users_role.update(role_id: 1)
  end


  ###### YOU NEED TO MAKE SURE THAT CITATION IS NOT DUPLICATE
  citations_project_dict = {}
  ####CHANGE THIS
  abstrackr_type = CitationType.find_by_name('Abstrackr')
 
  pmids_file =  File.read(Rails.root.join("lib", "tasks", "temp", "pmids.csv").to_s)
  pmids_csv = CSV.new(pmids_file, headers: false)
  
  old_citations.each do |old_c|
    #try to find citation
    citation = Citation.find_by({citation_type: abstrackr_type, name: old_c['title'], abstract: old_c['abstract'], refman: old_c['refman'],  pmid: old_c['pmid'] })

    #i wanted to use find_or_create_by but journal and keywords mess it up
    if citation.nil?
      citation = Citation.create!({citation_type: abstrackr_type, name: old_c['title'], abstract: old_c['abstract'], refman: old_c['refman'],  pmid: old_c['pmid'] })
    end

    #create journal
    if citation.journal.nil?
      citation.create_journal!({ name: old_c['journal'], publication_date: old_c['publication_date'] })
    end

    #create each author
    old_c['authors'].split(' and ').each do |author_name|
      if citation.authors.nil?
        citation.authors.build
      end
      citation.authors << Author.create!( name: author_name )
    end

    #create each keyword
    old_c['keywords'].split(',').each do |keyword|
      if citation.keywords.nil?
        citation.keywords.build
      end
      citation.keywords << Keyword.create!( name: keyword )
    end

    #i save after keywords and citations are created
    citation.save!

    #create citations_projects
    citations_project = CitationsProject.create!(citation: citation, project_id:project_dict[old_c['project_id']])
    citation.citations_projects << citations_project

    citations_project_dict[ old_c['id'] ] = citations_project.id
  end

  old_labels.each do |old_l|
    citations_project = CitationsProject.find(citations_project_dict[old_l['study_id']])
    label = Label.create!({ value: old_l['label'], citations_project: citations_project, user_id: user_dict[old_l['user_id']]})
  end

  task_type_dict = { 'conflict' => 'Conflict', 'initial' => 'Pilot', 'perpetual' => 'Perpetual', 'assigned' => 'Advanced' }

  task_dict = {}
  old_tasks.each do |old_t|
    task = Task.create!({ project_id: project_dict[old_t['project_id']], task_type: TaskType.find_by(name: task_type_dict[old_t['task_type']]), num_assigned: old_t['num_assigned'] })
    task_dict[ old_t['id'] ] = task.id
  end

  old_assignments.each do |old_a|
    assignment = Assignment.create!({ task_id: task_dict[old_a['task_id']], user_id: user_dict[old_a['user_id']], done_so_far: old_a['done_so_far'], date_assigned: old_a['date_assigned'], date_due: old_a['date_due'], done: old_a['done'] })
  end

  old_notes.each do |old_n|
    note_arr = []
    if not old_n['general'].nil?
      note_arr << 'General: ' + old_n['general']
    end
    if not old_n['population'].nil?
      note_arr << 'Population : ' + old_n['population']
    end
    if not old_n['ic'].nil?
      note_arr << 'Intervention/Comparator: ' + old_n['ic']
    end
    if not old_n['outcome'].nil?
      note_arr << 'Outcome: ' + old_n['outcome']
    end
    note_arr.each do |note_content|
      note = Note.find_or_create_by!({ user_id: user_dict[old_n['creator_id']], notable_type: CitationsProject.name, notable_id: citations_project_dict[old_n['citation_id']], value: note_content })
    end
  end

  ####currently this is missing the tag color, im not sure where tag color should live
  old_tags.each do |old_tag|
    tag_id = Tag.find_or_create_by({ name: old_tag }).id

    tagging = Tagging.find_or_create_by!({ user_id: user_dict[old_tag['creator_id']], taggable_type: CitationsProject.name, taggable_id: citations_project_dict[old_tag['citation_id']], tag_id: tag_id })

  end
end
