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
    :database => "abstrackr"
  ).connection

  old_citations = []
  abs_connection.exec_query('SELECT title, authors, publication_date FROM citations').rows.each do |row|
    old_citations << row[0] + " " + row[1]
  end

  File.open(Rails.root.join("lib", "tasks", "temp", "terms.txt"), "w+") do |f|
    f.puts(old_citations[0..200])
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
    :database => "abstrackr"
  ).connection

  #old_labels = abs_connection.exec_query('SELECT * FROM labels').to_hash
  old_users = abs_connection.exec_query('SELECT * FROM user').to_hash
  old_projects = abs_connection.exec_query('SELECT * FROM projects').to_hash
  old_citations = abs_connection.exec_query('SELECT * FROM citations').to_hash

  # connect to srdrPLUS
  srdr_connection = ActiveRecord::Base.establish_connection(
    :adapter  => "mysql2",
    :host     => "localhost",
    :username => "root",
    :password => "",
    :database => "srdrPLUS_development"
  ).connection
  
  old_users.each do |uu|
    puts uu['email']
    user = User.new({email: uu['email'], password:'password'})
    user.skip_confirmation!
    user.save
    user.create_profile({ username: uu['username'], first_name: uu['fullname'] })
    break
  end

  old_projects.each do |pp|
    puts pp['name']
    project = Project.create({ name: pp['name'], description: pp['description'] })
    break
  end

  ###### YOU NEED TO MAKE SURE THAT 
  old_citations.each do |cc|
    puts cc['title']
    citation = Citation.find_or_create_by({ name: pp['title'], abstract: cc['abstract'], refman: cc['refman'],  pmid: cc['pmid'] })
    citation.create_journal({ name: pp['journal'], publication_date: pp['publication_date']})


    break
  end
end
