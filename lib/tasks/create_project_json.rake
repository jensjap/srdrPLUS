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
  task import_projects: :environment do
    logger = ActiveSupport::Logger.new(Rails.root.join('tmp', 'json_exports', 'logs', 'import_projects_' + Time.now.to_i.to_s + '.log'))
    start_time = Time.now
    files_wildcard = Rails.root.join('tmp','json_exports', 'projects', '*.json') 
    json_files = Dir.glob files_wildcard
    projects_count = json_files.length

    logger.info "Task started at #{start_time}"

    json_files.each.with_index do |json_file, index|
      puts "#{Time.now.to_s} - Processing file: #{json_file}"
      begin
        fhash = JSON.parse(File.read(json_file))
      rescue
        logger.error "#{Time.now.to_s} - Cannot parse file as JSON: #{json_file}"
        next
      end

      phash = fhash["project"]

      if phash.nil?
        logger.error "#{Time.now.to_s} - JSON format not supported"
        next
      end

      Project.transaction do
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
        phash['users']&.each do |uid, uhash|
          puts "LOYLOY"
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

          uhash['roles']&.each do |rid, rhash|
            puts "LEYLEY"
            r = Role.find_by(name: rhash['name'])
            if r.present?
              pu.roles << r
            else
              logger.warning "#{Time.now.to_s} - Could not find role with name '" +  rhash['name'] + "' for user: '" + u.profile.username + "'"
            end
          end

          puts uhash
          uhash['term_groups']&.each do |tgid, tghash|
            puts "LAYLAYLOM"
            tg = TermGroup.find_or_create_by!(name: tghash['name'])
            ## Find by color?
            c = Color.find_by(name: tghash['color']['name'])
            if not c.present?
              c = Color.first
              logger.warning "#{Time.now.to_s} - Could not find color with name '" + tghash['color']['name'] + "', used '" + c.name + "' instead"
            end
            tgc = TermGroupsColor.find_or_create_by!({term_group: tg, color: c})
            pu.term_groups_colors << tgc
          
            p.save!
          end
        end
        puts "LOYLOY"

        # key_questions
        phash['key_questions']&.each do |kqid, kqhash|
          kq = KeyQuestion.find_or_create_by!(name: kqhash['name']) 
          p.key_questions << kq
        end

        #citations
        phash['citations']&.each do |cid, chash|
          j = Journal.find_or_create_by!(name: chash['journal'])

          kwarr = []
          chash['keywords']&.each do |kwid, kwhash|
            kw = Keyword.find_or_create_by!(name: kwhash['name'])
            kwarr << kw
          end

          auarr = []
          chash['authors']&.each do |aid, ahash|
            a = Author.find_or_create_by!(name: ahash['name'])
          end

          c = Citation.create!({
            name: chash['name'],
            abstract: chash['abstract'],
            refman: chash['refman'],
            pmid: chash['pmid'],
            publication_date: chash['publication_date'],
            keywords: kwarr,
            authors: auarr})

          p.citations << c

          cp = CitationsProject.find_by!(project: p, citation: c)
          
          chash['labels']&.each do |lid, lhash|
            pur = ProjectsUsersRole.find_by({
              project: p,
              user: User.find_by(name: phash['users'][lhash['labeler_user_id']]['name']),
              role: Role.find_by(name: phash['users'][lhash['labeler_user_id']]['roles'][lhash['labeler_role_id']]['name'])
            })
            lt = LabelType.find_by(name: lhash['label_type']['name'])
            l = Label.create!(citations_project: cp, projects_users_role: pur, label_type: lt)

            rarr = []
            lhash['reasons']&.each do |rid, rhash|
              rarr << Reason.find_or_create_by!(name: rhash['name'])
            end
            l.update!(reasons:rarr)
          end

          chash['tags']&.each do |tid, thash|
            pur = ProjectsUsersRole.find_by({
              project: p,
              user: User.find_by(name: phash['users'][thash['creator_user_id']]['name']),
              role: Role.find_by(name: phash['users'][thash['creator_user_id']]['roles'][thash['creator_role_id']]['name'])
            })
            t = Tag.find_or_create_by!(name: thash['name'])
            Tagging.create!({taggable_type: 'CitationsProject', 
                            taggable_id: cp.id, 
                            projects_users_role: pur, 
                            tag: t})
          end

          chash['notes']&.each do |nid, nhash|
            pur = ProjectsUsersRole.find_by({
              project: p,
              user: User.find_by(name: phash['users'][nhash['creator_user_id']]['name']),
              role: Role.find_by(name: phash['users'][nhash['creator_user_id']]['roles'][nhash['creator_role_id']]['name'])
            })
            cp.notes << Note.create!(projects_users_role: pur, name: nhash['name'])
          end
        end

        #tasks
        phash['tasks'].hash do |tid, thash|
          tt = TaskType.find_by(name: thash['task_type']['name'])
          na = thash['num_assigned']
          
          t = Task.create!(task_type: tt, num_assigned: na)

          aarr = []
          thash['assignments']&.each do |aid, ahash|
            pur = ProjectsUsersRole.find_by({
              project: p,
              user: User.find_by(name: phash['users'][ahash['assignee_user_id']]['name']),
              role: Role.find_by(name: phash['users'][ahash['assignee_user_id']]['roles'][ahash['assignee_role_id']]['name'])
            })

            t.assignments << Assignment.create!({projects_users_role: pur, 
                                                 done_so_far: ahash['dones_so_far'],
                                                 date_due: ahash['date_due'],
                                                 done: ahash['done']})
          end
        end

        phash['extraction_forms']&.each do |efpid, efhash|
          # i dont want to use this, but i guess it is necessary -birol
          t1_link_dict = {}
          efps_id_dict = {}

          efhash['sections']&.each do |sid, shash|
            #do we want to create sections that does not exist? -Birol
            s = Section.find_or_create_by!(name: shash['name'])
            efps_type = ExtractionFormsProjectsSectionType.find_by(name: shash['extraction_forms_projects_section_type'])
            
            t1arr = []
            shash['type1s']&.each do |t1hash|
              t1arr << Type1.find_or_create_by!(name: t1hash['name']['description'])
            end

            ### this is wrong, the id does not mean anything, also we have to do this at the end :/
            efps = ExtractionFormsProjectsSection.create!(extraction_forms_project: efp, link_to_type1: nil)

            Ordering.create!(orderable_type:'ExtractionFormsProjectsSection', orderable_id: efps.id, position: shash['position'])

            efps_id_dict[sid] = efps.id
            if link_to_type1.present?
              t1_link_dict[efps.id] = efhash['sections'][link_to_type1]
            end

            #create efps first
            efpsohash = shash['extraction_forms_projects_section_option'] 
            if efpsohash.present?
              ExtractionFormsProjectsSectionOption.create!(extraction_forms_projects_section: efps, by_type1: efpsohash['by_type1'], include_total: efpsohash['include_total'])
            end

            shash['questions']&.each do |qid, qhash|
              kqarr = []
              qhash['key_questions']&.each do |kqid, kqhash|
                # maybe storing the kq id earlier and using that would be better? -Birol
                kqarr << KeyQuestion.find_by(name: kqhash['name'])
              end

              q = Question.create! extraction_forms_projects_section: efps, name: qhash['name']

              # would this fire validations? -birol
              q.key_questions << kqarr

              qhash['question_rows']&.each do |qrid, qrhash|
                qr = QuestionRow.create!(question: q)
                qrhash['question_row_columns']&.each do |qrcid, qrchash|
                  # maybe use find_by and raise an error if not found? -Birol
                  qrc_type = QuestionRowColumnType.find_or_create_by! name: qrchash['question_row_column_type']['name']
                  qrc = QuestionRowColumn.create!(question_row: qr, question_row_column_type: qrc_type)

                  qrcoarr = []
                  qrchash['question_row_column_options']&.each do |qrcoid, qrcohash|
                    qrcoarr << QuestionRowColumnOption.find_or_create_byi!(name: qrcohash['name'])
                  end
                  qrc.question_row_column_options << qrcoarr

                  qrcfarr = []
                  qrchash['question_row_column_fields']&.each do |qrcfid, qrcohash|
                    qrcfarr << QuestionRowColumnField.find_or_create_by!(name: qrcfhash['name'])
                  end
                  qrc.question_row_column_fields << qrcfarr
                end
              end

              Ordering.create!(orderable_type: 'Question', orderable_id: q.id, position: qhash['position'])

            end
          end

          t1_link_dict.each do |t2_efps_id, t1_efps_source_id|
            ExtractionFormsProjectsSection.find(t2_efps_id).update!(link_to_type1: efps_id_dict[t1_efps_source_id])
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
