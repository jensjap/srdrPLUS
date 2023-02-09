namespace :abstrackr do

  desc "switch rails logger to stdout"
  task :verbose => [:environment] do
    Rails.logger = Logger.new(STDOUT)
  end

  desc "this creates the process of populating db with abstrackr data"
  task :populate_db => [:environment] do
    File.open(Rails.root.join("lib", "tasks", "temp", "pids.txt"), "w") {|file| file.truncate(0) }
    File.open(Rails.root.join("lib", "tasks", "temp", "done.txt"), "w") {|file| file.truncate(0) }

    create_pid_list

    thr = Thread.new do
      5.times do
        while true
          pid = ""
          File.open(Rails.root.join("lib", "tasks", "temp", "pids.txt"), "r+") do |f|
            f.flock(File::LOCK_EX)
            text_arr =  []
            f.each_line do |line|
              text_arr << line.strip
            end
            f.truncate(0)
            f.seek(0)
            pid = text_arr.pop
            f.puts text_arr
            f.flock(File::LOCK_UN)
          end

          if pid.nil? or pid.empty?
            break
          end
          process_project(pid)

          File.open(Rails.root.join("lib", "tasks", "temp", "done.txt"), "a") do |f|
            f.flock(File::LOCK_EX)
            f << (pid + "\n")
            f.flock(File::LOCK_UN)
          end
        end
      end
    end
    thr.join
  end

  def create_connection
    abs_connection = ActiveRecord::Base.establish_connection(
      :adapter  => "mysql2",
      :host     => "localhost",
      :username => "root",
      :password => "",
      :database => "abstrackr"
    ).connection

    return abs_connection
  end

  def create_pid_list
    abs_connection = create_connection

    pids = []
    abs_connection.exec_query('SELECT id FROM projects').rows.each do |row|
      pids << row[0]
    end

    File.open(Rails.root.join("lib", "tasks", "temp", "pids.txt"), "w+") do |f|
      #pids = ['2258']
      f.puts(pids.shuffle[0..20])
    end
  end

  def find_pmids
    abs_connection = create_connection

    abs_connection.exec_query('SELECT id, title, authors, publication_date FROM citations').rows.each do |row|
      old_citations << row[0].to_s + " ||||| " + row[1] + " " + row[2]
    end

    File.open(Rails.root.join("lib", "tasks", "temp", "terms.txt"), "w+") do |f|
      f.puts(old_citations)
    end

    system("python " + Rails.root.join("lib", "tasks", "helpers", "find_pmids.py").to_s + " " + Rails.root.join("lib", "tasks", "temp", "terms.txt").to_s + " " + Rails.root.join("lib", "tasks", "temp", "pmids.csv").to_s)
  end

  def my_log(f, str)
    f.flock(File::LOCK_EX)
    f.puts str
    f.flock(File::LOCK_UN)
  end


  def process_project(pid)
    #open file for logging
    log_file = File.open(Rails.root.join("lib", "tasks", "temp", "log.txt"), "w")
    log_file.truncate(0)

    # connect to Abstrackr
    abs_connection = create_connection

    #I wanted it to be able to handle multiple projects if needed. This may be stupid
    pids = [pid]

    #create empty lists to prevent headaches
    old_citations = []
    old_citations_tasks = []
    old_projects = []
    old_users_projects = []
    old_projects_leaders = []
    old_citations = []
    old_labels = []
    old_tasks = []
    old_assignments = []
    old_notes = []
    old_tags = []
    old_tagtypes = []


    if pids.length > 0;
      old_projects = abs_connection.exec_query('SELECT * FROM projects where id in (' + pids.join(',') + ')').to_hash

      old_users_projects = abs_connection.exec_query('SELECT * FROM users_projects where project_id in (' + pids.join(',') + ')').to_hash

      old_projects_leaders = abs_connection.exec_query('SELECT * FROM projects_leaders where project_id in (' + pids.join(',') + ')').to_hash

        old_citations = abs_connection.exec_query('SELECT * FROM citations where project_id in (' + pids.join(',') + ')').to_hash

        old_labels = abs_connection.exec_query('SELECT * FROM labels where project_id in (' + pids.join(',') + ')').to_hash

        old_tasks = abs_connection.exec_query('SELECT * FROM tasks where project_id in (' + pids.join(',') + ')').to_hash

    taskids = []
    old_tasks.each do |ot|
      taskids << ot['id']
    end

    citids = []
    old_citations.each do |oc|
      citids << oc['id']
    end

      old_assignments = abs_connection.exec_query('SELECT * FROM assignments where project_id in (' + pids.join(',') + ')').to_hash
    end

    if taskids.length > 0 and citids.length > 0
      old_citations_tasks = abs_connection.exec_query('SELECT * FROM citations_tasks where task_id in (' + taskids.join(',') + ') and citation_id in (' + citids.join(',') + ')').to_hash
    end

    if citids.length > 0
      old_notes = abs_connection.exec_query('SELECT * FROM notes where citation_id in (' + citids.join(',') + ')').to_hash

      old_tags = abs_connection.exec_query('SELECT * FROM tags where citation_id in (' + citids.join(',') + ')').to_hash
    end

    tagtypeids = []
    old_tags.each do |tag|
      tagtypeids << tag['tag_id']
    end

    if tagtypeids.length > 0
      old_tagtypes = abs_connection.exec_query('SELECT * FROM tagtypes where id in (' + tagtypeids.join(',') + ')').to_hash
    end

    #there are many places to look for users who are relevant to the project.
    #some of these may be unnecessary, for example labels by users who left the project
    #but let's not leave them just yet
    userids = []
    old_labels.each do |oup|
      userids << oup['user_id']
    end

    old_assignments.each do |opl|
      userids << opl['user_id']
    end

    old_notes.each do |opl|
      userids << opl['creator_id']
    end

    old_tags.each do |opl|
      userids << opl['creator_id']
    end

    old_users_projects.each do |oup|
      userids << oup['user_id']
    end

    old_projects_leaders.each do |opl|
      userids << opl['user_id']
    end

    userids = userids.uniq
    userids.delete(nil)

    if userids.length > 0
      old_users = abs_connection.exec_query('SELECT * FROM user where id in (' + userids.join(',') + ')').to_hash
    end

    # connect to srdrPLUS
    srdr_connection = ActiveRecord::Base.establish_connection(
      :adapter  => "mysql2",
      :host     => "localhost",
      :username => "root",
      :password => "",
      :database => "srdrplus_parsing_test"
    ).connection

    user_dict = {}

    #lets create the consensus user first
    user = User.find_by(email: 'consensus@consensus.com')
    if user.nil?
      user = User.new({email: 'consensus@consensus.com', password:'jP4M-nD8uUvmzhm5Aw'})
      user.skip_confirmation!
      user.save!
      user.profile.update({ username: 'consensus', first_name: 'consensus' })
    else
      my_log(log_file, "PID: " + pid.to_s + " consensus user does not exist")
    end
    user_dict[ 0 ] = user.id

    old_users.each do |old_u|
      user = User.find_by(email: old_u['email'])
      if user.nil?
        user = User.new({email: old_u['email'], password:'password'})
        user.skip_confirmation!
        user.save
        user.profile.update({ username: old_u['username'], first_name: old_u['fullname'] })
      else
        my_log(log_file, "PID: " + pid.to_s + " user does not exist. email: " + (old_u['email'] || "nil").to_s)
      end
      user_dict[ old_u['id'] ] = user.id
    end

    project_dict = {}
    old_projects.each do |old_p|
      old_p_name = old_p['name'] == '' ? 'UNTITLED' : old_p['name'] 
      begin
        project = Project.create!({ name: old_p_name, description: old_p['description'] })
        project_dict[ old_p['id'] ] = project.id
      rescue
        byebug
      end
    end

    old_users_projects.each do |old_u_p|
      if not (user_dict[old_u_p['user_id']].nil? or project_dict[old_u_p['project_id']].nil?)
        projects_user_id = ProjectsUser.find_or_create_by!({ project_id: project_dict[old_u_p['project_id']], user_id: user_dict[old_u_p['user_id']] }).id
        projects_users_role = ProjectsUsersRole.find_by({ projects_user_id: projects_user_id })
        if projects_users_role.nil?
          projects_users_role = ProjectsUsersRole.create!({ projects_user_id: projects_user_id, role_id: 2 })
        end
      else
        if user_dict[old_u_p['user_id']].nil? 
          my_log(log_file, "PID: " + pid.to_s + " user does not exist. old user id: " + (old_u_p['user_id'] || "nil").to_s)
        else
          my_log(log_file, "PID: " + pid.to_s + " project does not exist. old project id: " + (old_u_p['project_id'] || "nil").to_s)
        end
      end
    end

    old_projects_leaders.each do |old_p_l|
      if not (user_dict[old_p_l['user_id']].nil? or project_dict[old_p_l['project_id']].nil?)
        projects_user_id = ProjectsUser.find_or_create_by!({ project_id: project_dict[old_p_l['project_id']], user_id: user_dict[old_p_l['user_id']] }).id
        projects_users_role = ProjectsUsersRole.find_by({ projects_user_id: projects_user_id })
        if projects_users_role.nil?
          projects_users_role = ProjectsUsersRole.create!({ projects_user_id: projects_user_id, role_id: 1 })
        end
        projects_users_role.update(role_id: 1)
      end
    end


    ###### YOU NEED TO MAKE SURE THAT CITATION IS NOT DUPLICATE
    citations_project_dict = {}
    citation_dict = {}

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

      citation_dict[ old_c['id'] ] = citation.id

      #create journal
      if citation.journal.nil?
        citation.create_journal!({ name: old_c['journal'], publication_date: old_c['publication_date'] })
      end

      #create each author
      authors_len = old_c['authors'].length
      authors_arr = old_c['authors'].split(' and ')


      if authors_len/authors_arr.length.to_f > 40
        authors_arr = old_c['authors'].split("\n")
      end

      if authors_len/authors_arr.length.to_f > 40
        authors_arr = old_c['authors'].split(";")
      end

      authors_arr.delete("")

      authors_arr.each do |author_name|
        if citation.authors.nil?
          citation.authors.build
        end
        begin
          citation.authors << Author.create!( name: author_name.strip )
        rescue
          byebug
        end
      end

      #create each keyword
      #keyword parsing is currently an issue.
      #my idea is to try all separator strings and see which splits the string into shorter tokens. this is *not* fast, but there seems to be a ton of weird  keyword patterns.

      #decide on delimiter


#      cur_separator = ','
#      cur_max = 1
#      [',', '/', '|', '--', "\t", /(?<=\])\s(?=[^\[])/, ';'].each do |separator|
#        match_count = old_c['keywords'].scan(separator).count
#        if match_count > cur_max
#          cur_separator = separator
#          cur_max = match_count
#        end
#      end
#
#      if cur_max == 1
#        cur_separator = ' '
#      end
#
#      keywords = old_c['keywords'].split(cur_separator)
#
#      keywords.each do |keyword|
#        if citation.keywords.nil?
#          citation.keywords.build
#        end
#        begin
#          citation.keywords << Keyword.create!( name: keyword )
#        rescue
#          byebug
#        end
#      end

      citation.keywords << Keyword.create!( name: old_c['keywords'] )

      #i save after keywords and citations are created
      citation.save!

      #create citations_projects
      citations_project = CitationsProject.create!(citation: citation, project_id:project_dict[old_c['project_id']])
      citation.citations_projects << citations_project

      citations_project_dict[ old_c['id'] ] = citations_project.id
    end

    old_labels.each do |old_l|
      citations_project = CitationsProject.find(citations_project_dict[old_l['study_id']])
      if not (citations_project.nil? or user_dict[old_l['user_id']].nil?)
        label = Label.create!({ value: old_l['label'], citations_project: citations_project, user_id: user_dict[old_l['user_id']]})
      else
        if citations_project.nil?
          my_log(log_file, "PID: " + pid.to_s + " citations_project does not exist. old citation id: " + (old_l['study_id'] || "nil").to_s)
        else
          my_log(log_file, "PID: " + pid.to_s + " user does not exist. old user id: " + (old_l['user_id'] || "nil").to_s)
        end
      end
    end

    task_type_dict = { 'conflict' => 'Conflict', 'initial' => 'Pilot', 'perpetual' => 'Perpetual', 'assigned' => 'Advanced' }

    task_dict = {}
    old_tasks.each do |old_t|
      if not project_dict[old_t['project_id']].nil?
        task = Task.create!({ project_id: project_dict[old_t['project_id']], task_type: TaskType.find_by(name: task_type_dict[old_t['task_type']]), num_assigned: old_t['num_assigned'] })
        task_dict[ old_t['id'] ] = task.id
      else
        my_log(log_file, "PID: " + pid.to_s + " project does not exist. old project id: " + (old_t['project_id'] || "nil").to_s)
      end
    end

    old_citations_tasks.each do |old_c_t|
      begin
        if not (citation_dict[old_c_t['citation_id']].nil? or task_dict[old_c_t['task_id']].nil?)
          citations_task = CitationsTask.create!({ citation_id: citation_dict[old_c_t['citation_id']], task_id: task_dict[old_c_t['task_id']] })
        else
          if citation_dict[old_c_t['citation_id']].nil?
            my_log(log_file, "PID: " + pid.to_s + " citations does not exist. old citation id: " + (old_c_t['citation_id'] || "nil").to_s)
          else
            my_log(log_file, "PID: " + pid.to_s + " task does not exist. old task id: " + (old_c_t['task_id'] || "nil").to_s)
          end
        end
      rescue
        byebug
      end
    end

    old_assignments.each do |old_a|
      begin
        if not (user_dict[old_a['user_id']].nil? or project_dict[old_a['project_id']].nil?)
          projects_user = ProjectsUser.find_by!({ project_id: project_dict[old_a['project_id']], user_id: user_dict[old_a['user_id']] })
        else
          if user_dict[old_a['user_id']].nil? 
            my_log(log_file, "PID: " + pid.to_s + " user does not exist. old user id: " + (old_a['user_id'] || "nil").to_s)
          else
            my_log(log_file, "PID: " + pid.to_s + " project does not exist. old project id: " + old_a['project_id'].to_s)
          end
        end
        if not projects_user.nil?
          projects_users_role = ProjectsUsersRole.find_by({ projects_user_id: projects_user.id  })
        else
          my_log(log_file, "PID: " + pid.to_s + " projects_user does not exist. old user id: " + (old_a['user_id'] || "nil").to_s + ". old project id: " + (old_a['project_id'] || "nil").to_s)
        end
        if not projects_users_role.nil?
          assignment = Assignment.create!({ task_id: task_dict[old_a['task_id']], projects_users_role: projects_users_role, done_so_far: old_a['done_so_far'], date_assigned: old_a['date_assigned'], date_due: old_a['date_due'], done: old_a['done'] })
        else
          my_log(log_file, "PID: " + pid.to_s + " projects_user_role does not exist. old user id: " + (old_a['user_id'] || "nil").to_s + ". old project id: " + (old_a['project_id'] || "nil").to_s)
        end
      rescue
        byebug
      end
    end

    old_notes.each do |old_n|
      note_arr = []
      if not old_n['general'].nil?
        note_arr << 'General: ' + old_n['general']
      end
      if not old_n['population'].nil?
        note_arr << 'Population: ' + old_n['population']
      end
      if not old_n['ic'].nil?
        note_arr << 'Intervention/Comparator: ' + old_n['ic']
      end
      if not old_n['outcome'].nil?
        note_arr << 'Outcome: ' + old_n['outcome']
      end
      note_arr.each do |note_content|
        if not ( user_dict[old_n['creator_id']].nil? or citations_project_dict[old_n['citation_id']].nil?)
          note = Note.find_or_create_by!({ user_id: user_dict[old_n['creator_id']], notable_type: CitationsProject.name, notable_id: citations_project_dict[old_n['citation_id']], value: note_content })
        else
          if user_dict[old_n['creator_id']].nil?
            my_log(log_file, "PID: " + pid.to_s + " user does not exist. old user id: " + (old_a['user_id'] || "nil").to_s)
          else
            my_log(log_file, "PID: " + pid.to_s + " citations_project does not exist. old citation id: " + (old_a['citation_id'] || "nil").to_s) 
          end
        end
      end
    end

    ####currently this is missing the tag color, im not sure where tag color should live
    tag_dict = {}
    begin
      old_tagtypes.each do |old_tagtype|
        tag = Tag.find_or_create_by({ name: old_tagtype['text'] })
        tag_dict[ old_tagtype['id'] ] = tag.id
      end
    rescue
      byebug
    end

    old_tags.each do |old_tag|
      if not (user_dict[old_tag['creator_id']].nil? or citations_project_dict[old_tag['citation_id']].nil? or citations_project_dict[old_tag['citation_id']].nil?)
        tagging = Tagging.find_or_create_by!({ user_id: user_dict[old_tag['creator_id']], taggable_type: CitationsProject.name, taggable_id: citations_project_dict[old_tag['citation_id']], tag_id: tag_dict[old_tag['tag_id']] })
      else
        if user_dict[old_n['creator_id']].nil?
          my_log(log_file, "PID: " + pid.to_s + "user does not exist. old user id: " + (old_a['user_id'] || "nil").to_s)
        else
          my_log(log_file, "PID: " + pid.to_s + "citations_project does not exist. old citation id: " + (old_a['citation_id'] || "").to_s)
        end
      end
    end

    log_file.close()
  end
end
