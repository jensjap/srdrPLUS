module JsonImporters
  class ProjectImporter
    def initialize(logger)
      # we need to store stuff like the project, so an instance variable maybe?
      @p = Project.new
      @efp = nil
      @logger = logger

      @role_id_dict = {}
      @color_id_dict = {}

      @user_id_dict = {}
      @tg_id_dict = {}
      @kqp_id_dict = {}
      @cp_id_dict = {}
      @qrcf_id_dict = {}
      @t1_id_dict = {}
      @efps_id_dict = {}
      @eefps_id_dict = {}
      @eefpst1_id_dict = {}
      @tp_id_dict = {}
      @pop_id_dict = {}
      @comp_id_dict = {}

      @section_dedup_dict = {}
      @question_dedup_dict = {}

      @t1_link_dict = {}
      @eefps_t1_link_dict = {}

      @section_position_tuples = []

      @question_position_counter_dict = {}
      @question_position_tuples_dict = {}
    end

    def import_project(phash)
      Project.transaction do

        ## PROJECT INFO
        @p.update!({
                       name: phash['name'],
                       description: phash['description'],
                       attribution: phash['attribution'],
                       methodology_description: phash['methodology_description'],
                       prospero: phash['prospero'],
                       doi: phash['doi'],
                       notes: phash['notes'],
                       funding_source: phash['funding_source']})
        @efp = @p.extraction_forms_projects.first

        ## KEY QUESTIONS
        phash['key_questions']&.each(&method(:import_key_question))

        ## USERS
        phash['users']&.each(&method(:import_user))

        ## CITATIONS
        phash['citations']&.each(&method(:import_citation))

        ## TASKS
        phash['tasks']&.values&.each(&method(:import_task))

        ## EFPSs
        position_counter = 0
        phash['extraction_forms']&.values&.each do |efhash|
          efhash['sections']&.each do |sid, shash|
            linked_shash = nil
            if shash['link_to_type1'].present?
              linked_shash = efhash['sections']['link_to_type1']
            end
            import_efps(sid, shash, linked_shash, position_counter)
          end
          position_counter += (0 || efhash['sections'].length)
        end

        # does this work? TEST!
        @question_position_tuples_dict.values&.each do |q_tuples|
          q_tuples.sort { |tuple| tuple[0] }
          q_tuples.each.with_index do |tuple, index|
            q = tuple[1]
            q.ordering.position = index + 1
          end
        end

        # does this work? TEST!
        @t1_link_dict.each do |t2_efps_id, t1_efps_source_id|
          ExtractionFormsProjectsSection.find(t2_efps_id).update!(link_to_type1: @efps_id_dict[t1_efps_source_id])
        end

        # does this work? TEST!
        @section_position_tuples.sort { |tuple| tuple[0] }
        @section_position_tuples.each.with_index do |tuple, index|
          efps = tuple[1]
          efps.ordering.position = index + 1
        end

        ## EXTRACTIONS
        phash['extractions']&.values&.each do |ehash|
          import_extraction(ehash)
        end

      end
      @p.id
    end

    def import_user(uid, uhash)
      # is this enough to identify a user or should we check profile as well??
      u = User.find_by({id: uid, email: uhash['email']})

      if u.nil?
        temp_password = "Please_Update_Your_Password"
        u = User.create!(email: uhash['email'], password: temp_password)
        profile_hash = uhash['profile']
        o =  Organization.find_or_create_by!(name: profile_hash['organization']['name'])
        Profile.find_or_create_by!({user:         u,
                                    username:     profile_hash['username'],
                                    first_name:   profile_hash['first_name'],
                                    middle_name:  profile_hash['middle_name'],
                                    last_name:    profile_hash['last_name'],
                                    time_zone:    profile_hash['time_zone'],
                                    organization: o})

      end

      @user_id_dict[uid.to_i] = u

      pu = ProjectsUser.find_or_create_by!({project: @p, user: u})

      uhash['roles']&.each do |rid, rhash|
        r = find_role(rid, rhash['name'])
        ProjectsUsersRole.find_or_create_by(projects_user: pu, role: r)
      end

      uhash['term_groups']&.values&.each do |tghash|
        tg = TermGroup.find_or_create_by!(name: tghash['name'])
        c = find_color(tghash['color']['id'], tghash['color']['name'])
        tgc = TermGroupsColor.find_or_create_by!({term_group: tg, color: c})
        putgc = ProjectsUsersTermGroupsColor.find_or_create_by!(projects_user: pu, term_groups_color: tgc)

        tghash['terms']&.values&.each do |thash|
          t = Term.find_or_create_by!(name: thash['name'])
          ProjectsUsersTermGroupsColorsTerm.find_or_create_by!(projects_users_term_groups_color: putgc, term: t)
        end
      end
    end

    def import_key_question(kqpid, kqhash)
      kqp = @kqp_id_dict[kqpid]
      if kqp.present? then return kqp end

      kq = KeyQuestion.find_or_create_by!(name: kqhash['name'])
      kqp = KeyQuestionsProject.find_or_create_by(project: @p, key_question: kq)
      @kqp_id_dict[kqpid] = kqp
    end

    def find_role(rid, role_name)
      #check dictionary first
      r =  @role_id_dict[rid.to_i]
      if r.present? then return r end

      #then try to find it by name
      r = Role.find_by(name: role_name)
      if r.present?
        @role_id_dict[rid.to_i] = r
        return r
      end

      #if can't find, use Contributor
      r = Role.find_by(name: 'Contributor')
      @logger.warning "#{Time.now.to_s} - Could not find role with name '" +  role_name + "' for user: '" + u.profile.username + "', used 'Contributor' instead"
      @role_id_dict[rid.to_i] = r
      return r
    end

    def find_color(cid, color_name)
      #this is probably a bad way to find the color
      c = @color_id_dict[cid]
      if c.present? then return c end

      c = Color.find_by(name: color_name)
      if c.present?
        @color_id_dict[cid] = c
        return c
      end

      ## try to use different colors
      c = Color.where.not( id: @color_id_dict.values.map {|c| c.id} ).first
      @logger.warning "#{Time.now.to_s} - Could not find color with name '" + color_name + "', used '" + c.name + "' instead"
      @color_id_dict[cid] = c
      return c
    end

    def find_projects_user(uid)
      u = @user_id_dict[uid]
      if u.present?
        return ProjectsUser.find_by(project: @p, user: u)
      end
      return nil
    end

    def find_projects_users_role(uid, rid)
      u = @user_id_dict[uid]
      r = @role_id_dict[rid]

      if u.present? and r.present?
        pu = ProjectsUser.find_by(project: @p, user: u)
        return ProjectsUsersRole.find_by!(projects_user: pu, role: r)
      end
      return nil
    end

    def import_citation(cpid, chash)
      if @cp_id_dict[cpid].present? then return @cp_id_dict[cpid] end

      j = Journal.find_or_create_by!(name: chash['journal']['name'])

      c = Citation.create!({name: chash['name'],
                            abstract: chash['abstract'],
                            refman: chash['refman'],
                            pmid: chash['pmid'],
                            journal: j})

      chash['keywords']&.values&.each do |kwhash|
        kw = Keyword.find_or_create_by!(name: kwhash['name'])
        c.keywords << kw
      end

      chash['authors']&.values&.each do |ahash|
        a = Author.find_or_create_by!(name: ahash['name'])
        c.authors << a
      end

      cp = CitationsProject.find_or_create_by! project: @p, citation: c

      chash['labels']&.values&.each do |lhash|
        pur = find_projects_users_role(lhash['labeler_user_id'], lhash['labeler_role_id'])
        lt = LabelType.find_by(name: lhash['label_type']['name'])
        l = Label.create!(citations_project: cp, projects_users_role: pur, label_type: lt)

        lhash['reasons']&.values&.each do |rhash|
          r = Reason.find_or_create_by!(name: rhash['name'])
          LabelsReason.find_or_create_by!(projects_users_role: pur, reason: r, label: l)
        end
      end

      chash['tags']&.values&.each do |thash|
        pur = find_projects_users_role(thash['creator_user_id'], thash['creator_role_id'])
        t = Tag.find_or_create_by!(name: thash['name'])
        Tagging.create!({taggable_type: 'CitationsProject',
                         taggable_id: cp.id,
                         projects_users_role: pur,
                         tag: t})
      end

      chash['notes']&.values&.each do |nhash|
        pur = find_projects_users_role(nhash['creator_user_id'], nhash['creator_role_id'])
        Note.create!({projects_users_role: pur,
                      notable_type: 'CitationsProject',
                      notable_id: cp.id,
                      value: nhash['value']})
      end
      cp = CitationsProject.find_or_create_by!(citation: c, project: @p)
      @cp_id_dict[cpid.to_i] = cp
    end

    def import_task(thash)
      tt = TaskType.find_by(name: thash['task_type']['name'])
      if tt.nil?
        tt = TaskType.first
        logger.warning "#{Time.now.to_s} - Could not find task_type with name '" + thash['task_type']['name'] + ", used '" + tt.name + "' instead."
      end
      na = thash['num_assigned']

      t = Task.create!(project: @p, task_type: tt, num_assigned: na)

      thash['assignments']&.values&.each do |ahash|
        pur = find_projects_users_role(ahash['assignee_user_id'], ahash['assignee_role_id'])

        t.assignments << Assignment.create!({projects_users_role: pur,
                                             done_so_far: ahash['dones_so_far'],
                                             date_due: ahash['date_due'],
                                             done: ahash['done']})
      end
    end

    def get_dedup_key(shash, linked_shash)
      efps_type_name = shash['extraction_forms_projects_section_type']['name']
      section_name = shash['section']['name']
      if efps_type_name == "Type 1"
        return "<<<#{section_name}&&#{efps_type_name}&&#{(shash['type1s']&.map {|t1hash| t1hash['name']}).sort.join("||")}>>>"
      elsif efps_type_name == "Type 2"
        return "<<<#{section_name}&&#{efps_type_name}&&#{(linked_shash['type1s']&.map {|t1hash| t1hash['name']}).sort.join("||")}>>>"
      elsif efps_type_name == "Results"
        ## there should only ever be one results section?
        return "<<<#{efps_type_name}>>>"
      end
    end

    def figure_out_efps_type(shash)
      if shash['questions'] or shash['link_to_type1']
        return ExtractionFormsProjectsSectionType.find_by name: 'Type 2'
      elsif shash['type1s']
        return ExtractionFormsProjectsSectionType.find_by name: 'Type 1'
      else
        return ExtractionFormsProjectsSectionType.find_by name: 'Results'
      end
    end

    def import_efps(sid, shash, linked_shash, position_counter)
      #if this is a duplicate section, we just want to return the original
      dedup_key = get_dedup_key shash, linked_shash
      efps = @section_dedup_dict[dedup_key]
      if efps.present? then return efps end

      efps = @efps_id_dict[sid]
      if efps.present? then return efps end

      #do we want to create sections that does not exist? -Birol
      s = Section.find_or_create_by! name: shash['section']['name']
      efps_type = ExtractionFormsProjectsSectionType.find_by! name: shash['extraction_forms_projects_section_type']['name']

      if efps_type.nil?
        efps_type = figure_out_efps_type shash
        logger.warning "#{Time.now.to_s} - Could not find extraction_forms_projects_section_type with name '" +  shash['extraction_forms_projects_section_type']['name'] + ", used '" + efps_type.name + "' instead."
      end

      if efps.nil?
        efps = ExtractionFormsProjectsSection.find_or_create_by! extraction_forms_project: @efp,
                                                                 extraction_forms_projects_section_type: efps_type,
                                                                 section: s
        @section_position_tuples << [shash['position'].to_i + position_counter, efps]

        link_to_type1 = shash['link_to_type1']
        if link_to_type1.present?
          @t1_link_dict[efps.id] = link_to_type1
        end

        shash['type1s']&.each do |t1id, t1hash|
          t1 = Type1.find_or_create_by!(name: t1hash['name'], description: t1hash['description'])
          efps.type1s << t1
          @t1_id_dict[t1id] = t1
        end

        #create efps first
        efpsohash = shash['extraction_forms_projects_section_option']
        if efpsohash.present?
          ExtractionFormsProjectsSectionOption.create!({extraction_forms_projects_section: efps,
                                                        by_type1: efpsohash['by_type1'],
                                                        include_total: efpsohash['include_total']})
        end
      end

      @question_position_counter_dict[efps.id] ||= 0
      @question_position_tuples_dict[efps.id] ||= []
      @question_dedup_dict[efps.id] ||= {}

      shash['questions']&.values&.each do |qhash|
        import_question(efps, qhash)
      end
      @question_position_counter_dict[efps.id] += (shash['questions'] || []).length

      @efps_id_dict[sid] = efps
    end

    def import_question(efps, qhash)
      q = Question.create! extraction_forms_projects_section: efps,
                       name: qhash['name'],
                       description: qhash['description']

      q_hash_key = "q: <<<" + qhash['name'].to_s + ">>> "
      qhash['key_questions']&.each do |kqid, kqhash|
        # maybe storing the kq id earlier and using that would be better? -Birol
        q_hash_key += "kq: <<<" + kqhash['name'].to_s + ">>> "
        q.key_questions_projects << @kqp_id_dict[kqid]
      end

      qhash['question_rows']&.values&.each_with_index do |qrhash, ri|
        q_hash_key += "qr: <<<" + qrhash['name'].to_s + ">>> "

        if ri == 0
          qr = QuestionRow.find_by!(question: q)
        else
          qr = QuestionRow.new(question: q)
        end
        qr.update!(name: qrhash['name'])

        qrhash['question_row_columns']&.values&.each_with_index do |qrchash, ci|
          # maybe use find_by and raise an error if not found? -Birol
          q_hash_key += "qrc: <<<" + qrchash['name'].to_s + ">>> "

          qrc_type = QuestionRowColumnType.find_or_create_by! name: qrchash['question_row_column_type']['name']

          p qrc_type

          qrc = nil
          if ci == 0
            qrc = QuestionRowColumn.find_by! question_row: qr
          else
            qrc = QuestionRowColumn.new question_row: qr
          end

          qrc.update! question_row_column_type: qrc_type,
                      name: qrchash['name']
          p qrc

          qrc.question_row_columns_question_row_column_options.destroy_all
          # can i prevent creation of default options to begin with
          qrchash['question_row_columns_question_row_column_options']&.values&.each do |qrcqrcohash|
            qrcohash = qrcqrcohash['question_row_column_option']
            qrco = QuestionRowColumnOption.find_or_create_by! name: qrcohash['name']
            qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find_or_create_by! question_row_column: qrc,
                                                                         question_row_column_option: qrco,
                                                                         name: qrcqrcohash['name']

          end

          qrchash['question_row_column_fields']&.each do |qrcfid, qrcfhash|
            qrcf = QuestionRowColumnField.find_or_create_by!(question_row_column: qrc, name: qrcfhash['name'])
            @qrcf_id_dict[qrcfid] = qrcf
          end
        end
      end

      if @question_dedup_dict[efps.id][q_hash_key].nil?
        @question_dedup_dict[efps.id][q_hash_key] = q
        @question_position_tuples_dict[efps.id] << [qhash['position'].to_i + @question_position_counter_dict[efps.id], q]
      else
        # not very elegant to destroy question if it is a duplicate, but I dont want to traverse the same question structure multiple times
        q.destroy
      end
    end

    def import_eefpst1(eefps, eefpst1hash)
      t1hash = eefpst1hash['type1']
      t1 = @t1_id_dict[t1hash['id']]

      if t1.nil?
        t1 = Type1.find_or_create_by!(name: t1hash['name'], description: t1hash['description'])
        @t1_id_dict[t1hash['id']] = t1
      end

      t1_type = nil
      if t1hash['type1_type'].present?
        t1_type = Type1Type.find_by(name: t1hash['type1_type']['name'])
        if t1_type.nil?
          t1_type = Type1Type.first
          logger.warning "#{Time.now.to_s} - Could not find type1_type with name #{t1hash['type1_type']['name']} , used #{t1_type.name} instead"
          ## maybe we should just use nil in this case
        end
      end

      eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.find_by! extractions_extraction_forms_projects_section: eefps,
                                                                         type1: t1

      ## I dont want to create duplicate t1 associations, so I use find_by!, then update
      eefpst1.update! ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by! extractions_extraction_forms_projects_section: eefps,
                                                                                         type1: t1,
                                                                                         units: t1hash['units'],
                                                                                         type1_type: t1_type
    end

    def import_population

    end


    def import_extraction(ehash)
      cp = @cp_id_dict[ehash['citation_id']]
      pur = find_projects_users_role(ehash['extractor_user_id'], ehash['extractor_role_id'])

      e = Extraction.create! project: @p, projects_users_role: pur, citations_project: cp

      ehash['sections']&.each do |sid, shash|
        efps = @efps_id_dict[sid]

        # this has to be already there, because I'm counting on the callback and validations
        eefps = ExtractionsExtractionFormsProjectsSection.find_by! extraction: e,
                                                                   extraction_forms_projects_section: efps

        @eefps_id_dict[sid.to_i] = eefps

        #if shash['link_to_t1'].present?
        #  @eefps_t1_link_dict[eefps.id] = shash['link_to_t1']
        #end

        shash['extractions_extraction_forms_projects_sections_type1s']&.each do |eefpst1id, eefpst1hash|
          @eefpst1_id_dict[eefpst1id.to_i] = import_eefpst1(eefps, eefpst1hash)
        end
      end

      # here I use 2 loops where technically we should be able to get away with 1,
      # but it is hard to make sure no timepoint_id points to eefpst1 not yet created

      ehash['sections']&.each do |sid, shash|
        eefps = @eefps_id_dict[sid]

        shash['extractions_extraction_forms_projects_sections_type1s']&.each do |eefpst1id, eefpst1hash|
          eefpst1 = @eefpst1_id_dict[eefpst1id.to_i]

          eefpst1hash['populations']&.each do |popid, pophash|
            pop_name = PopulationName.find_or_create_by! name: pophash['population_name']['name']
            pop = ExtractionsExtractionFormsProjectsSectionsType1Row.find_or_create_by! extractions_extraction_forms_projects_sections_type1: eefpst1,
                                                                                        population_name: pop_name

            @pop_id_dict[popid.to_i] = pop

            pophash['timepoints']&.each do |tpid, tphash|
              tp_name = TimepointName.find_or_create_by! name: tphash['timepoint_name']['name'],
                                                         unit: tphash['timepoint_name']['unit']
              tp = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_or_create_by! extractions_extraction_forms_projects_sections_type1_row: pop,
                                                                                               timepoint_name: tp_name
              @tp_id_dict[tpid.to_i] = tp
            end

            pophash['result_statistic_sections']&.values&.each do |rsshash|
              rss_type = ResultStatisticSectionType.find_or_create_by!({name: rsshash['result_statistic_section_type']['name']})

              rss = ResultStatisticSection.find_or_create_by! result_statistic_section_type: rss_type,
                                                              population: pop

              rsshash['comparisons']&.keys&.each do |compid|
                comp = Comparison.create!
                ComparisonsResultStatisticSection.create! result_statistic_section: rss, comparison: comp
                @comp_id_dict[compid.to_i] = comp
              end

              ## comparisons are sometimes referring to other comparisons, so they all must be created beforehand

              rsshash['comparisons']&.each do |compid, comphash|
                comp = @comp_id_dict[compid.to_i]
                comphash['comparate_groups']&.values&.each do |cghash|
                  cg = ComparateGroup.create! comparison: comp
                  cghash['comparates']&.values&.each do |cchash|
                    cehash = cchash['comparable_element']
                    if cehash['comparable_type'] == 'ExtractionsExtractionFormsProjectsSectionsType1'
                      ce = ComparableElement.create! comparable_type: 'ExtractionsExtractionFormsProjectsSectionsType1',
                                                     comparable_id: @eefpst1_id_dict[cehash['comparable_id']]&.id
                      Comparate.create! comparate_group: cg,
                                        comparable_element: ce

                    elsif cehash['comparable_type'] == 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn'
                      ce = ComparableElement.create! comparable_type: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn',
                                                     comparable_id: @tp_id_dict[cehash['comparable_id']]&.id
                      Comparate.create! comparate_group: cg,
                                        comparable_element: ce
                    elsif cehash['comparable_type'] == 'Comparison'
                      ce = ComparableElement.create! comparable_type: 'Comparison',
                                                     comparable_id: @comp_id_dict[cehash['comparable_id']]&.id
                      Comparate.create! comparate_group: cg,
                                        comparable_element: ce
                    else
                      logger.error "#{Time.now.to_s} - Unknown comparable_type"
                      ### YOU NEED TO ABORT COMPARISON CREATION
                    end
                  end
                end
              end

              rsshash['result_statistic_sections_measures']&.each do |rssmid, rssmhash|
                m = Measure.find_or_create_by!(name: rssmhash['measure']['name'])
                rssm = ResultStatisticSectionsMeasure.find_or_create_by!({result_statistic_section: rss,
                                                                          measure: m})

                if rssmhash['records'].present?
                  rssmhash['records']['tps_comparisons_rssms']&.values&.each do |tchash|
                    tcr = TpsComparisonsRssm.create!({timepoint: @tp_id_dict[tchash['timepoint_id']],
                                                      comparison: @comp_id_dict[tchash['comparison_id']],
                                                      result_statistic_sections_measure: rssm})

                    Record.create!({recordable_type: 'TpsComparisonsRssm',
                                    recordable_id: tcr.id,
                                    name: tchash['record_name']})

                  end
                  rssmhash['records']['tps_arms_rssms']&.values&.each do |tahash|
                    tar = TpsArmsRssm.create!({timepoint: @tp_id_dict[tahash['timepoint_id']],
                                               extractions_extraction_forms_projects_sections_type1: @eefpst1_id_dict[tahash['arm_id']],
                                               result_statistic_sections_measure: rssm})

                    Record.create!({recordable_type: 'TpsArmsRssm',
                                    recordable_id: tar.id,
                                    name: tahash['record_name']})
                  end
                  rssmhash['records']['comparisons_arms_rssms']&.values&.each do |cahash|
                    car = ComparisonsArmsRssm.create!({comparison: @comp_id_dict[cahash['comparison_id']],
                                                       extractions_extraction_forms_projects_sections_type1: @eefpst1_id_dict[cahash['arm_id']],
                                                       result_statistic_sections_measure: rssm})

                    Record.create!({recordable_type: 'ComparisonsArmsRssm',
                                    recordable_id: car.id,
                                    name: cahash['record_name']})
                  end
                  rssmhash['records']['wacs_bacs_rssms']&.values&.each do |wbhash|
                    tcr = WacsBacsRssm.create!({wac: @comp_id_dict[wbhash['wac_id']],
                                                bac: @comp_id_dict[wbhash['bac_id']],
                                                result_statistic_sections_measure: rssm})

                    Record.create!({recordable_type: 'WacsBacsRssm',
                                    recordable_id: tcr.id,
                                    name: wbhash['record_name']})
                  end
                end
              end
            end
          end

        end

        ### THIS IS REDUNDANT?
        ### DOES THIS WORK? TEST!!
        #@eefps_t1_link_dict.each do |t2_eefps_id, t1_eefps_source_id|
        #  ExtractionsExtractionFormsProjectsSection.find(t2_eefps_id).update!(link_to_type1: @eefps_id_dict[t1_eefps_source_id])
        #end

        shash['records']&.each do |qrcfid, rhash|
          qrcf = @qrcf_id_dict[qrcfid]
          eefpsqrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by! extractions_extraction_forms_projects_section: eefps,
                                                                                                          qrcf: qrcf

          Record.find_or_create_by!({recordable_type: 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField',
                                     recordable_id: eefpsqrcf.id,
                                     name: rhash['name']})
        end
      end
    end
  end
end