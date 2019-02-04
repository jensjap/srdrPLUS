require 'json'

namespace :project_json do
  desc "Creates a json export of the given project"
  task export_projects: :environment do
    projects = []
    if ENV['pid'].present?
      projects = Project.where(id: ENV['pid'])
    else
      projects = Project.all
    end

    File.open(Rails.root.join('public','json_exports','logs', '/export_projects.log'), "w+") do |f|
      log = ActiveSupport::Logger.new(f)
    end
    start_time = Time.now
    projects_count = projects.length

    log.info "Task started at #{start_time}"

    projects.each do |index, project|
      puts "Processing Project ID #{project.id}"
      project_json_content = ApplicationController.render(template: 'api/v1/projects/export.json', assigns: { project: project })

      if project_json_content
        log.info "#{index}/#{projects_count} - project_id: #{user.id}"
      else
        log.info "#{index}/#{projects_count} - project_id: #{user.id} - errors: #{project_json_content.errors}"
      end

      file_folder  = Rails.root.join('public','json_exports','projects')
        #file = File.read(file_folder.join(file_name + ".json"))
        #fields = JSON.parse(form)
        #updated_fields = set_fields(fields)
      File.open(file_folder.join("project_" + project.id + ".json"), "w") do |f|
        f.truncate 0
        f.puts project_json_content
      end
      if File.read(file_folder.join("project_" + project.id + ".json")).length > 0
        puts "JSON successfully written: public/json_exports/projects/project_" + project.id + ".json"
      end

      log.info "Task finished at #{end_time} and last #{duration} minutes."
      log.close
    end
  end

  desc "Reads a json export of the given project and imports it into srdrPLUS"
  task import_project: :environment do
    if ENV['file'].nil? then raise 'No file provided. Usage: file=<file_path>' end
    projects_hash = JSON.parse(File.read(Rails.root.join(ENV['file'])))['project']

    log = ActiveSupport::Logger.new(Rails.root.join('public', 'json_exports', 'logs', '/import_projects.log'))
    start_time = Time.now
    projects_count = projects_hash.length

    log.info "Task started at #{start_time}"

    projects_hash.each do |pid, phash|
      # We need to check if certain parts of a project are already in database, and use info in json to check references
      # Ignore project id since we're creating a new one
      
      #if Project.find_by( id: phash['id'], name: phash['name'], description: phash['description'] ).present?
      #  raise 'Project already exists in srdrPLUS'
      #end

      Project.transaction do
        p = Project.new 
        p.name = phash['name']
        p.description = phash['description']
        p.attribution = phash['attribution']
        p.methodology_description = phash['methodology_description']
        p.prospero = phash['prospero']
        p.doi = phash['doi']
        p.notes = phash['notes']
        p.funding_source = phash['funding_source']
        p.save

        phash['users'].each do |uhash|
          uid = uhash.keys.first        
          uhash = uhash[uid]
          
          # is this enough to identify a user or should we check profile as well??
          u = User.find_by({id: uid, email: uhash['email']})

          if u.present?
            p.users << u
          else
            User.transaction(requires_new: true) do
              u = User.create(email: uhash['email'])
              profile = uhash['profile']
              Profile.transaction(requires_new: true) do
                u.profile = Profile.create({username: profile['username'],
                                            first_name: profile['first_name'],
                                            middle_name: profile['middle_name'],
                                            last_name: profile['last_name'],
                                            time_zone: profile['time_zone']})

                o =  Organization.find_by(name: profile['organization']['name'])
                if o.present?
                  u.profile.organization = o
                else
                  Organization.transaction(requires_new: true) do
                    u.profile.organization.create(name: profile['organization'])
                  end
                end
              end
            end
          end

          pu = ProjectsUser.find_by({project: p, user: u})

          uhash['roles'].each do |rhash|
            rhash = rhash[rid]
            r = Role.find_by(name: rhash['name'])
            if r.present?
              pu.roles << r
            end
          end

          uhash['term_groups'].each do |tghash|
            tgid = tghash.keys.first
            tghash = tghash[tgid]
            
            tg = TermGroup.find_or_create_by(name: tghash['name'])
            c = Color.find_by(name: tghash['color']['name']) || Color.first
            tgc = TermGroupsColor.find_or_create_by({term_group: tg, color: c})
          end
        end
      end
    end
  end
end
