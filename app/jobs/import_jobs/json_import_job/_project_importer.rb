class ProjectImporter
  def initialize(project)
    # we need to store stuff like the project, so an instance variable maybe?
    @p = project

    @id_map = {}

    @id_map['color'] = {}
    @id_map['comparison'] = {}
    @id_map['cp'] = {}
    @id_map['efps'] = {}
    @id_map['eefps'] = {}
    @id_map['eefpst1'] = {}
    @id_map['kqp'] = {}
    @id_map['population'] = {}
    @id_map['qrcf'] = {}
    @id_map['qrcqrco'] = {}
    @id_map['question'] = {}
    @id_map['role'] = {}
    @id_map['t1'] = {}
    @id_map['tp'] = {}
    @id_map['user'] = {}

    @dedup_map = {}
    @dedup_map['efps'] = {}
    @dedup_map['question'] = {}

    @t1_link_dict = {}
    @eefps_t1_link_dict = {}
    @question_dependency_dict = {}

    @section_position_tuples = []

    @question_position_counter_dict = {}
    @question_position_tuples_dict = {}
  end

  def import_project(phash)
    Project.transaction do

      ## PROJECT INFO
      @p.update!({
                     name: phash['name'] || @p.name,
                     description: phash['description'] || @p.description,
                     attribution: phash['attribution'] || @p.attribution,
                     methodology_description: phash['methodology_description'] || @p.methodology_description,
                     prospero: phash['prospero'] || @p.prospero,
                     doi: phash['doi'] || @p.doi,
                     notes: phash['notes'] || @p.notes,
                     funding_source: phash['funding_source'] || @p.funding_source})

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
        q_tuples.sort! { |t1, t2| t1[0] <=> t2[0] }
        q_tuples.each.with_index do |tuple, index|
          q = tuple[1]
          begin
            q.ordering.update!( position: index + 1 )
          rescue
            byebug
          end
        end
      end

      ## QUESTION DEPENDENCIES
      @question_dependency_dict.each do |question_id, depenarr|
        depenarr.each do |prehash|
          create_dependency question_id, prehash
        end
      end

      # does this work? TEST!
      @t1_link_dict.each do |t2_efps_id, t1_efps_source_id|
        ExtractionFormsProjectsSection.find(t2_efps_id).update!(link_to_type1: @id_map['efps'][t1_efps_source_id.to_s])
      end

      # does this work? TEST!
      @section_position_tuples.sort! { |t1, t2| t1[0] <=> t2[0] }
      @section_position_tuples.each.with_index do |tuple, index|
        efps = tuple[1]
        efps.ordering.update!( position: index + 1 )

      end

      ## EXTRACTIONS
      phash['extractions']&.values&.each do |ehash|
        import_extraction(ehash)
      end

    end
    @p.id
  end

  def create_dependency(question_id, prehash)
    case prehash['prerequisitable_type']
    when 'Question'
      Dependency.find_or_create_by! dependable_type: 'Question',
                                    dependable_id: question_id,
                                    prerequisitable_type: 'Question',
                                    prerequisitable_id: @id_map['question'][prehash['prerequisitable_id'].to_s].id
    when 'QuestionRowColumnField'
      Dependency.find_or_create_by! dependable_type: 'Question',
                                    dependable_id: question_id,
                                    prerequisitable_type: 'QuestionRowColumnField',
                                    prerequisitable_id: @id_map['qrcf'][prehash['prerequisitable_id'].to_s].id
    when 'QuestionRowColumnsQuestionRowColumnOption'
      Dependency.find_or_create_by! dependable_type: 'Question',
                                    dependable_id: question_id,
                                    prerequisitable_type: 'QuestionRowColumnsQuestionRowColumnOption',
                                    prerequisitable_id: @id_map['qrcqrco'][prehash['prerequisitable_id'].to_s].id
    end
  end

  def import_user(uid, uhash)
    # is this enough to identify a user or should we check profile as well??
    u = User.find_by(email: uhash['email'])

    if u.nil?
      temp_password = "Please_Update_Your_Password"
      u = User.create!(email: uhash['email'], password: temp_password)

      ## If the user is already in the system, don't change the profile
      profile_hash = uhash['profile']

      o = Organization.find_or_create_by! name: profile_hash['organization']['name']

      uname = profile_hash['username']
      if u.profile.username != uname and not Profile.find_by(username: uname).nil?
        while not Profile.find_by(username: uname).nil?
          uname += rand(10).to_s
        end
        Rails.logger.debug "Username #{profile_hash['username']} is taken, using #{uname} for email #{uhash['email']} instead."
      end

      profile = u.profile.update! username:     uname,
                                  first_name:   profile_hash['first_name'],
                                  middle_name:  profile_hash['middle_name'],
                                  last_name:    profile_hash['last_name'],
                                  time_zone:    profile_hash['time_zone'],
                                  organization: o

      profile_hash['degrees']&.values&.each do |dhash|
        d = Degree.find_or_create_by! name: dhash['name']
        DegreesProfile.find_or_create_by! degree: d,
                                          profile: profile
      end
    end

    @id_map['user'][uid.to_i] = u

    pu = ProjectsUser.find_or_create_by!({project: @p, user: u})

    uhash['roles']&.each do |rid, rhash|
      r = find_role(rid, rhash['name'])
      ProjectsUsersRole.find_or_create_by!(projects_user: pu, role: r)
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
    kqp = @id_map['kqp'][kqpid]
    if kqp.present? then return kqp end

    kq = KeyQuestion.find_or_create_by!(name: kqhash['name'])
    kqp = KeyQuestionsProject.find_or_create_by!(project: @p, key_question: kq)
    @id_map['kqp'][kqpid] = kqp
  end

  def find_role(rid, role_name)
    #check dictionary first
    r =  @id_map['role'][rid.to_i]
    if r.present? then return r end

    #then try to find it by name
    r = Role.find_by(name: role_name)
    if r.present?
      @id_map['role'][rid.to_i] = r
      return r
    end

    #if can't find, use Contributor
    r = Role.find_by(name: 'Contributor')
    Rails.logger.debug "Could not find role with name '" +  role_name + "' for user: '" + u.profile.username + "', used 'Contributor' instead"
    @id_map['role'][rid.to_i] = r
    return r
  end

  def find_color(cid, color_name)
    #this is probably a bad way to find the color
    c = @id_map['color'][cid]
    if c.present? then return c end

    c = Color.find_by(name: color_name)
    if c.present?
      @id_map['color'][cid] = c
      return c
    end

    ## try to use different colors
    c = Color.where.not( id: @id_map['color'].values.map {|c| c.id} ).first
    Rails.logger.debug "Could not find color with name '" + color_name + "', used '" + c.name + "' instead"
    @id_map['color'][cid] = c
    return c
  end

  def find_projects_user(uid)
    u = @id_map['user'][uid]
    if u.present?
      return ProjectsUser.find_by(project: @p, user: u)
    end
    return nil
  end

  def find_projects_users_role(uid, rid)
    u = @id_map['user'][uid]
    r = @id_map['role'][rid]

    if u.present? and r.present?
      pu = ProjectsUser.find_by(project: @p, user: u)
      return ProjectsUsersRole.find_by!(projects_user: pu, role: r)
    end
    return nil
  end

  def import_citation(cpid, chash)
    if @id_map['cp'][cpid].present? then return @id_map['cp'][cpid] end

    j = Journal.find_or_create_by!(name: chash['journal']['name'])

    c = Citation.create!({citation_type: CitationType.first,
                          name: chash['name'],
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
    @id_map['cp'][cpid.to_i] = cp
  end

  def import_task(thash)
    tt = TaskType.find_by(name: thash['task_type']['name'])
    if tt.nil?
      tt = TaskType.first
      Rails.logger.debug "Could not find task_type with name '" + thash['task_type']['name'] + ", used '" + tt.name + "' instead."
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

  def get_efps_dedup_key(shash, linked_shash)
    efps_type_name = shash['extraction_forms_projects_section_type']['name']
    section_name = shash['section']['name']
    if efps_type_name == "Type 1" and shash['type1s'].present?
      return "<<<#{section_name}&&#{efps_type_name}&&#{(shash['type1s']&.values&.map {|t1hash| t1hash['name']}).sort.join("||")}>>>"
    elsif efps_type_name == "Type 2" and linked_shash.present? and linked_shash['type1s'].present?
      return "<<<#{section_name}&&#{efps_type_name}&&#{(linked_shash&['type1s']&.values&.map {|t1hash| t1hash['name']}).sort.join("||")}>>>"
    elsif efps_type_name == "Results"
      ## there should only ever be one results section?
      return "<<<#{efps_type_name}>>>"
    else
      return "<<<#{section_name}&&#{efps_type_name}>>>"
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
    efps = @id_map['efps'][sid]
    if efps.present? then return efps end

    #if this is a duplicate section, we just want to return the original
    dedup_key = get_efps_dedup_key shash, linked_shash
    efps = @dedup_map['efps'][dedup_key]
    if efps.present?
      @id_map['efps'][sid] = efps
      return efps
    end

    #do we want to create sections that does not exist? -Birol
    s = Section.find_or_create_by! name: shash['section']['name']
    efps_type = ExtractionFormsProjectsSectionType.find_by! name: shash['extraction_forms_projects_section_type']['name']

    if efps_type.nil?
      efps_type = figure_out_efps_type shash
      Rails.logger.debug "Could not find extraction_forms_projects_section_type with name '" +  shash['extraction_forms_projects_section_type']['name'] + ", used '" + efps_type.name + "' instead."
    end

    if efps.nil?
      efps = ExtractionFormsProjectsSection.find_or_create_by! extraction_forms_project: @p.extraction_forms_projects.first,
                                                               extraction_forms_projects_section_type: efps_type,
                                                               section: s
      @section_position_tuples << [shash['position'].to_i + position_counter, efps]

      link_to_type1 = shash['link_to_type1']
      if link_to_type1.present?
        @t1_link_dict[efps.id] = link_to_type1
      end

      shash['extraction_forms_projects_sections_type1s']&.values&.each do |efpst1hash|
        t1 = get_type1 efpst1hash['type1']
        t1_type = get_type1_type efpst1hash['type1_type']

        ExtractionFormsProjectsSectionsType1.find_or_create_by! extraction_forms_projects_section: efps,
                                                                type1: t1,
                                                                type1_type: t1_type
        @id_map['t1'][efpst1hash['type1']['id']] = t1
      end

      #create efps first
      efpsohash = shash['extraction_forms_projects_section_option']
      if efpsohash.present?
        ExtractionFormsProjectsSectionOption.create! extraction_forms_projects_section: efps,
                                                     by_type1: efpsohash['by_type1'],
                                                     include_total: efpsohash['include_total']
      end
    end

    @question_position_counter_dict[efps.id] ||= 0
    @question_position_tuples_dict[efps.id] ||= []
    @dedup_map['question'][efps.id] ||= {}

    q_with_dep = []
    shash['questions']&.each do |qid, qhash|
      if qhash['dependencies'].present?
        q_with_dep << [qid, qhash]
        next
      end
      import_question(efps, qid, qhash)
    end

    abort_counter = 0
    abort_limit = q_with_dep.length
    while not q_with_dep.empty?
      if abort_counter >= abort_limit
        Rails.logger.debug "There was a problem with importing questions with dependencies, there may be cyclical dependency"
        break
      end

      qid, qhash = q_with_dep.pop
      if not import_question(efps, qid, qhash)
        q_with_dep.unshift [qid, qhash]
      end
    end

    @question_position_counter_dict[efps.id] += (shash['questions'] || []).length

    @id_map['efps'][sid] = efps
    @dedup_map['efps'] = efps
  end

  def get_question_dedup_key(qhash)
    q_dedup_key = "q: <<<" + qhash['name'].to_s + ">>> "
    qhash['key_questions']&.each do |kqid, kqhash|
      q_dedup_key += "kq: <<<" + kqhash['name'].to_s + ">>> "
    end
    qhash['question_rows']&.values&.each_with_index do |qrhash, ri|
      q_dedup_key += "qr: <<<" + qrhash['name'].to_s + ">>> "
      qrhash['question_row_columns']&.values&.each_with_index do |qrchash, ci|
        q_dedup_key += "qrc: <<<" + qrchash['name'].to_s + ">>> "
      end
    end
    q_dedup_key += "dependencies: <<<"
    qhash['dependencies']&.each do |did,dhash|
      case dhash['prerequisitable_type']
      when 'Question'
        q = @id_map['question'][dhash['prerequisitable_id'].to_s]
        if q.nil?
          return false
        end
        q_dedup_key += "(Question, #{q.id})"
      when 'QuestionRowColumnField'
        qrcf = @id_map['qrcf'][dhash['prerequisitable_id'].to_s]
        if qrcf.nil?
          return false
        end
        q_dedup_key += "(QuestionRowColumnField, #{qrcf.id})"
      when 'QuestionRowColumnsQuestionRowColumnOption'
        qrcqrco = @id_map['qrcqrco'][dhash['prerequisitable_id'].to_s]
        if qrcqrco.nil?
          return false
        end
        q_dedup_key += "(QuestionRowColumnsQuestionRowColumnOption, #{qrcqrco.id})"
      end
    end
    q_dedup_key += ">>>"
    return q_dedup_key
  end

  def import_question(efps, qid, qhash)
    if @id_map['question'][qid].present?
      return @id_map['eefpst1'][qid]
    end

    q_dedup_key = get_question_dedup_key(qhash)
    if q_dedup_key.nil?
      return false
    end
    if @dedup_map['question'][efps.id][q_dedup_key].present?
      @id_map['question'][qid] = @dedup_map['question'][efps.id][q_dedup_key]
      return @dedup_map['question'][efps.id][q_dedup_key]
    end


    q = Question.create! extraction_forms_projects_section: efps,
                         name: qhash['name'],
                         description: qhash['description']

    @question_dependency_dict[q.id] = []
    qhash['dependencies']&.values&.each do |dephash|
      @question_dependency_dict[q.id] << dephash
    end

    qhash['key_questions']&.keys&.each do |kqid|
      # maybe storing the kq id earlier and using that would be better? -Birol
      KeyQuestionsProjectsQuestion.find_or_create_by! key_questions_project: @id_map['kqp'][kqid],
                                                      question: q
    end

    qhash['question_rows']&.values&.each_with_index do |qrhash, ri|

      if ri == 0
        qr = QuestionRow.find_by!(question: q)
      else
        qr = QuestionRow.new(question: q)
      end
      qr.update!(name: qrhash['name'])

      qrcarr = qr.question_row_columns.order('id ASC')

      qrhash['question_row_columns']&.values&.each_with_index do |qrchash, ci|
        # maybe use find_by and raise an error if not found? -Birol

        qrc_type = QuestionRowColumnType.find_by! name: qrchash['question_row_column_type']['name']

        if ri == 0 and ci == 0
          qrc = QuestionRowColumn.find_by! question_row: qr
        elsif ri == 0
          qrc = QuestionRowColumn.create! question_row: qr,
                                          question_row_column_type: qrc_type
        else
          qrc = qrcarr[ci]
        end

        qrc.update! question_row_column_type: qrc_type,
                    name: qrchash['name']

        qrc.question_row_columns_question_row_column_options.destroy_all
        # can i prevent creation of default options to begin with
        qrchash['question_row_columns_question_row_column_options']&.each do |qrcqrcoid, qrcqrcohash|
          qrcohash = qrcqrcohash['question_row_column_option']
          qrco = QuestionRowColumnOption.find_or_create_by! name: qrcohash['name']
          qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find_or_create_by! question_row_column: qrc,
                                                                                 question_row_column_option: qrco,
                                                                                 name: qrcqrcohash['name']

          @id_map['qrcqrco'][qrcqrcoid] = qrcqrco
        end

        qrcfarr = qrc.question_row_column_fields.order('id ASC')
        qrchash['question_row_column_fields']&.keys&.each_with_index do |qrcfid, fi|
          qrcf = qrcfarr[fi]
          @id_map['qrcf'][qrcfid] = qrcf
        end
      end
    end
    @dedup_map['question'][efps.id][q_dedup_key] = q
    @question_position_tuples_dict[efps.id] << [qhash['position'].to_i + @question_position_counter_dict[efps.id], q]
    @id_map['question'][qid] = q
  end

  def get_type1(t1hash)
    if t1hash.nil? then return end
    t1 = @id_map['t1'][t1hash['id']]
    if t1.nil?
      t1 = Type1.find_or_create_by!(name: t1hash['name'], description: t1hash['description'])
      if t1.suggestion.nil?
        Suggestion.create! suggestable_type: 'Type1', suggestable_id: t1.id, user_id: 1
      end
      @id_map['t1'][t1hash['id']] = t1
    end
    return t1
  end

  def get_type1_type(t1typehash)
    if t1typehash.nil? then return end
    t1_type = Type1Type.find_by(name: t1typehash['name'])
    if t1_type.nil?
      t1_type = Type1Type.first
      Rails.logger.debug "Could not find type1_type with name #{t1typehash['name']} , used #{t1_type.name} instead"
      ## maybe we should just use nil in this case
    end
    return t1_type
  end

  def import_eefpst1(eefps, eefpst1hash)
    t1 = get_type1 eefpst1hash['type1']
    t1_type = get_type1_type eefpst1hash['type1_type']

    eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by! extractions_extraction_forms_projects_section: eefps,
                                                                                 type1: t1,
                                                                                 type1_type: t1_type


    ## I dont want to create duplicate t1 associations, so I use find_or_create_by!, then update!
    eefpst1.update! extractions_extraction_forms_projects_section: eefps,
                    type1: t1,
                    units: eefpst1hash['units'],
                    type1_type: t1_type
    return eefpst1
  end

  def import_population

  end


  def import_extraction(ehash)
    cp = @id_map['cp'][ehash['citation_id']]
    pur = find_projects_users_role(ehash['extractor_user_id'], ehash['extractor_role_id'])

    e = Extraction.create! project: @p, projects_users_role: pur, citations_project: cp

    ehash['sections']&.each do |sid, shash|
      efps = @id_map['efps'][sid]

      # this has to be already there, because I'm counting on the callback and validations
      eefps = ExtractionsExtractionFormsProjectsSection.find_by! extraction: e,
                                                                 extraction_forms_projects_section: efps

      @id_map['eefps'][sid.to_i] = eefps

      #if shash['link_to_t1'].present?
      #  @eefps_t1_link_dict[eefps.id] = shash['link_to_t1']
      #end

      shash['extractions_extraction_forms_projects_sections_type1s']&.each do |eefpst1id, eefpst1hash|
        @id_map['eefpst1'][eefpst1id.to_i] = import_eefpst1(eefps, eefpst1hash)
      end
    end

    # here I use 2 loops where technically we should be able to get away with 1,
    # but it is hard to make sure no timepoint_id points to eefpst1 not yet created

    ehash['sections']&.each do |sid, shash|
      eefps = @id_map['eefps'][sid.to_i]

      shash['extractions_extraction_forms_projects_sections_type1s']&.each do |eefpst1id, eefpst1hash|
        eefpst1 = @id_map['eefpst1'][eefpst1id.to_i]

        eefpst1hash['populations']&.each do |popid, pophash|
          pop_name = PopulationName.find_or_create_by! name: pophash['population_name']['name'], description: (pophash['population_name']['description'] || "")
          pop = ExtractionsExtractionFormsProjectsSectionsType1Row.find_or_create_by! extractions_extraction_forms_projects_sections_type1: eefpst1,
                                                                                      population_name: pop_name

          @id_map['population'][popid.to_i] = pop

          pophash['timepoints']&.each do |tpid, tphash|
            tp_name = TimepointName.find_or_create_by! name: tphash['timepoint_name']['name'],
                                                       unit: tphash['timepoint_name']['unit']
            tp = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_or_create_by! extractions_extraction_forms_projects_sections_type1_row: pop,
                                                                                             timepoint_name: tp_name
            @id_map['tp'][tpid.to_i] = tp
          end

          pophash['result_statistic_sections']&.values&.each do |rsshash|
            rss_type = ResultStatisticSectionType.find_by!({name: rsshash['result_statistic_section_type']['name']})

            rss = ResultStatisticSection.find_or_create_by! result_statistic_section_type: rss_type,
                                                            population: pop

            rsshash['comparisons']&.each do |compid, comphash|
              comp = Comparison.create! is_anova: comphash["is_anova"]
              ComparisonsResultStatisticSection.create! result_statistic_section: rss, comparison: comp
              @id_map['comparison'][compid.to_i] = comp
            end

            ## comparisons are sometimes referring to other comparisons, so they all must be created beforehand

            rsshash['comparisons']&.each do |compid, comphash|
              comp = @id_map['comparison'][compid.to_i]
              comphash['comparate_groups']&.values&.each do |cghash|
                cg = ComparateGroup.create! comparison: comp
                cghash['comparates']&.values&.each do |cchash|
                  cehash = cchash['comparable_element']
                  if cehash['comparable_type'] == 'ExtractionsExtractionFormsProjectsSectionsType1'
                    ce = ComparableElement.create! comparable_type: 'ExtractionsExtractionFormsProjectsSectionsType1',
                                                   comparable_id: @id_map['eefpst1'][cehash['comparable_id']]&.id
                    Comparate.create! comparate_group: cg,
                                      comparable_element: ce

                  elsif cehash['comparable_type'] == 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn'
                    ce = ComparableElement.create! comparable_type: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn',
                                                   comparable_id: @id_map['tp'][cehash['comparable_id']]&.id
                    Comparate.create! comparate_group: cg,
                                      comparable_element: ce
                  elsif cehash['comparable_type'] == 'Comparison'
                    ce = ComparableElement.create! comparable_type: 'Comparison',
                                                   comparable_id: @id_map['comparison'][cehash['comparable_id']]&.id
                    Comparate.create! comparate_group: cg,
                                      comparable_element: ce
                  else
                    Rails.logger.debug "Unknown comparable_type"
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
                  begin
                  tcr = TpsComparisonsRssm.create!({timepoint: @id_map['tp'][tchash['timepoint_id']],
                                                    comparison: @id_map['comparison'][tchash['comparison_id']],
                                                    result_statistic_sections_measure: rssm})
                  rescue
                    byebug
                  end

                  Record.create!({recordable_type: 'TpsComparisonsRssm',
                                  recordable_id: tcr.id,
                                  name: tchash['record_name']})

                end
                rssmhash['records']['tps_arms_rssms']&.values&.each do |tahash|
                  tar = TpsArmsRssm.create!({timepoint: @id_map['tp'][tahash['timepoint_id']],
                                             extractions_extraction_forms_projects_sections_type1: @id_map['eefpst1'][tahash['arm_id']],
                                             result_statistic_sections_measure: rssm})

                  Record.create!({recordable_type: 'TpsArmsRssm',
                                  recordable_id: tar.id,
                                  name: tahash['record_name']})
                end
                rssmhash['records']['comparisons_arms_rssms']&.values&.each do |cahash|
                  car = ComparisonsArmsRssm.create!({comparison: @id_map['comparison'][cahash['comparison_id']],
                                                     extractions_extraction_forms_projects_sections_type1: @id_map['eefpst1'][cahash['arm_id']],
                                                     result_statistic_sections_measure: rssm})

                  Record.create!({recordable_type: 'ComparisonsArmsRssm',
                                  recordable_id: car.id,
                                  name: cahash['record_name']})
                end
                rssmhash['records']['wacs_bacs_rssms']&.values&.each do |wbhash|
                  tcr = WacsBacsRssm.create!({wac: @id_map['comparison'][wbhash['wac_id']],
                                              bac: @id_map['comparison'][wbhash['bac_id']],
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
      #  ExtractionsExtractionFormsProjectsSection.find(t2_eefps_id).update!(link_to_type1: @id_map['eefps'][t1_eefps_source_id])
      #end

      shash['records']&.each do |rid, rhash|
        qrcfid = rhash['question_row_column_field_id'].to_s
        qrcf = @id_map['qrcf'][qrcfid]
        if qrcf.nil?; byebug end
        qrc_type_name = qrcf.question_row_column.question_row_column_type.name
        eefpst1 = @id_map['eefpst1'][rhash['extractions_extraction_forms_projects_sections_type1_id']]
        eefpsqrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by! extractions_extraction_forms_projects_section: eefps,
                                                                                                        extractions_extraction_forms_projects_sections_type1: eefpst1,
                                                                                                        question_row_column_field: qrcf
        record_name = rhash['name'] || ""

        case qrc_type_name
        when 'checkbox'
          checkedarr = record_name[1..-2]&.gsub('"', '')&.split(", ")
          new_record_name = '["'

          checkedarr&.each do |checked_id|
            qrcqrco = @id_map['qrcqrco'][checked_id]
            new_record_name += "#{qrcqrco&.id&.to_s}\", \""
          end

          new_record_name += '"]'
          record_name = new_record_name
        when 'dropdown', 'radio'
          qrcqrco = @id_map['qrcqrco'][record_name]
          record_name = qrcqrco&.id&.to_s
        end

        Record.find_or_create_by! recordable_type: 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField',
                                  recordable_id: eefpsqrcf.id,
                                  name: (record_name || "")
      end
    end
  end
end
