require 'json'

namespace :project_json do
  desc "Creates a json export of the given project"
  task export_projects: :environment do
    projects = []
    if ENV['pids'].present?
      pids = ENV['pids'].split(",")
      projects = Project.where(id: pids)
    else
      projects = Project.all
    end

    logger = ActiveSupport::Logger.new(Rails.root.join('tmp','json_exports','logs', 'export_projects_' + Time.now.to_i.to_s + '.log'))
    start_time = Time.now
    projects_count = projects.length

    logger.info "Task started at #{start_time}"

    projects.each.with_index do |project, index|
      puts "#{Time.now.to_s} - Processing Project ID #{project.id}"
      project_json_content = ApplicationController.render(template: 'api/v1/projects/export.json', assigns: { project: project })

      if not project_json_content.empty?
        logger.info "#{index}/#{projects_count} - project_id: #{project.id}"
      else
        logger.info "#{index}/#{projects_count} - project_id: #{project.id} - errors: #{project_json_content.errors}"
      end

      file_folder  = Rails.root.join('tmp','json_exports','projects')
        #file = File.read(file_folder.join(file_name + ".json"))
        #fields = JSON.parse(form)
        #updated_fields = set_fields(fields)
      File.open(file_folder.join("project_" + project.id.to_s + ".json"), "w+") do |f|
        f.truncate 0
        f.puts project_json_content
      end
      if File.read(file_folder.join("project_" + project.id.to_s + ".json")).length > 0
        puts "#{Time.now.to_s} - JSON successfully written: tmp/json_exports/projects/project_" + project.id.to_s + ".json"
      end
    end
    end_time = Time.now
    duration = (end_time - start_time) / 1.minute
    logger.info "Task finished at #{end_time} and last #{duration} minutes."
    logger.close
  end

  desc "Reads a json export of the given project and imports it into srdrPLUS"
  task import_project: :environment do
    logger = ActiveSupport::Logger.new(Rails.root.join('tmp', 'json_exports', 'logs', '/import_projects_' + Time.now.to_i.to_s + '.log'))
    start_time = Time.now
    projects_count = json_files.length

    logger.info "Task started at #{start_time}"

    json_files.each.with_index do |json_file, index|
      puts "#{Time.now.to_s} - Processing file: #{json_file}"
      projects_hash = JSON.parse(File.read(json_file))['project']

      Transaction do
        p = Project.new 
        p.update!({ 
          name: phash['name'],
          description: phash['description'],
          attribution: phash['attribution'],
          methodology_description: phash['methodology_description'],
          prospero: phash['prospero'],
          doi: phash['doi'],
          notes: phash['notes'],
          funding_source: phash['funding_source']})

        # users
        phash['users'].each do |uid, uhash|
          # is this enough to identify a user or should we check profile as well??
          u = User.find_by({id: uid, email: uhash['email']})

          if u.present?
            p.users << u
          else
            u = User.create(email: uhash['email'])
            profile = uhash['profile']
            u.profile = Profile.create({username: profile['username'],
                                        first_name: profile['first_name'],
                                        middle_name: profile['middle_name'],
                                        last_name: profile['last_name'],
                                        time_zone: profile['time_zone']})

            o =  Organization.find_by(name: profile['organization']['name'])
            if o.present?
              u.profile.organization = o
            else
              u.profile.organization.create(name: profile['organization'])
            end
          end

          pu = ProjectsUser.find_by({project: p, user: u})

          uhash['roles'].each do |rid, rhash|
            r = Role.find_by(name: rhash['name'])
            if r.present?
              pu.roles << r
            else
              logger.warning "#{Time.now.to_s} - Could not find role with name '" +  rhash['name'] + "' for user: '" + u.profile.username + "'"
            end
          end

          uhash['term_groups'].each do |tgid, tghash|
            
            tg = TermGroup.find_or_create_by(name: tghash['name'])
            ## Find by color?
            c = Color.find_by(name: tghash['color']['name'])
            if not c.present?
              c = Color.first
              logger.warning "#{Time.now.to_s} - Could not find color with name '" + tghash['color']['name'] + "', used '" + c.name + "' instead"
            end
            tgc = TermGroupsColor.find_or_create_by({term_group: tg, color: c})
            pu.term_groups_colors << tgc
          
            p.save!
          end
        end

        # keywords
        phash['key_questions'].each do |kqid, kqhash|
          kq = KeyQuestion.find_or_create_by(name: kqhash['name']) 
          p.key_questions << kq
        end

        #citations
        phash['citations'].each do |cid, chash|
          c = Citation.new
          j = Journal.find_or_create_by(name: chash['journal'])

          kwarr = []
          chash['keywords'].each do |kwid, kwhash|
            kw = Keyword.find_or_create_by(name: kwhash['name'])
            kwarr << kw
          end

          auarr = []
          chash['authors'].each do |aid, ahash|
            a = Author.find_or_create_by(name: ahash['name'])
          end

          c.update!({
            name: chash['name'],
            abstract: chash['abstract'],
            refman: chash['refman'],
            pmid: chash['pmid'],
            publication_date: chash['publication_date'],
            keywords: kwarr,
            authors: auarr})

          c.save

          p.citations << c

          cp = CitationsProject.find_by!(project: p, citation: c)
          
          chash['labels'].each do |lid, lhash|
          end

          
        end
          
          
        end
      end
    end

    #if ENV['file'].nil? then raise 'No file provided. Usage: file=<file_path>' end



    #projects_hash.each do |pid, phash|
      # We need to check if certain parts of a project are already in database, and use info in json to check references
      # Ignore project id since we're creating a new one
      
      #if Project.find_by( id: phash['id'], name: phash['name'], description: phash['description'] ).present?
      #  raise 'Project already exists in srdrPLUS'
      #end

    end
  end
end
