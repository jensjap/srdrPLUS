module SeedData
  def self.extended(object)
    object.instance_exec do
      # Turn off paper_trail.
      PaperTrail.enabled = false

      # Roles.
      Role.create([
        { name: 'Leader'},
        { name: 'Contributor'},
        { name: 'Auditor'}
      ])

      # Users.
      @superadmin = User.create do |u|
        u.email        = 'superadmin@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @contributor = User.create do |u|
        u.email        = 'contributor@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @auditor = User.create do |u|
        u.email        = 'auditor@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @test_public = User.create do |u|
        u.email        = 'test_public@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      # for assignments
      @screener_1 = User.create do |u|
        u.email        = 'screener_1@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @screener_2 = User.create do |u|
        u.email        = 'screener_2@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @screener_3 = User.create do |u|
        u.email        = 'screener_3@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @screeners = [@screener_1, @screener_2, @screener_3]

      @organizations = Organization.create([
        { name: 'Brown University' },
        { name: 'Johns Hopkins University' }
      ])

      # Organizations.
      @cochrane = Organization.create(name: 'Cochrane')
      @red_hair_pirates = Organization.create(name: 'Red Hair Pirates')
      @straw_hat_pirates = Organization.create(name: 'Straw Hat Pirates')
      @roger_pirates = Organization.create(name: 'Roger Pirates')

      # Add data to seed profiles.
      # Profiles are created in after_create callback in user model.
      @superadmin.profile.update(
        organization: @red_hair_pirates,
        username: 'superadmin',
        first_name: 'Red',
        middle_name: 'Haired',
        last_name: 'Shanks')
      @contributor.profile.update(
        organization: @straw_hat_pirates,
        username: 'contributor',
        first_name: 'Monkey',
        middle_name: 'D',
        last_name: 'Luffy')
      @auditor.profile.update(
        organization: @straw_hat_pirates,
        username: 'auditor',
        first_name: 'Nico',
        middle_name: '',
        last_name: 'Robin')
      @test_public.profile.update(
        organization: @roger_pirates,
        username: 'test_public',
        first_name: 'Gol',
        middle_name: 'D',
        last_name: 'Roger')
      @screener_1.profile.update(
        organization: @roger_pirates,
        username: 'screener_1',
        first_name: 'Arthur',
        middle_name: 'C',
        last_name: 'Clarke')
      @screener_2.profile.update(
        organization: @roger_pirates,
        username: 'screener_2',
        first_name: 'Isaac',
        middle_name: '',
        last_name: 'Asimov')
      @screener_3.profile.update(
        organization: @roger_pirates,
        username: 'screener_3',
        first_name: 'Douglas',
        middle_name: 'Noel',
        last_name: 'Adams')

      # Degrees.
      @bachelor_arts = Degree.create(name: 'Bachelor of Arts - BA')
      @bachelor_science = Degree.create(name: 'Bachelor of Science - BS')
      @master_arts = Degree.create(name: 'Master of Arts - MA')
      @master_science = Degree.create(name: 'Master of Science - MS')
      @msph = Degree.create(name: 'Master of Science in Public Health - MSPH')
      @jd = Degree.create(name: 'Juris Doctor - JD')
      @md = Degree.create(name: 'Medical Doctor - MD')
      @phd = Degree.create(name: 'Doctor of Philosophy - PhD')

      # Suggestions.
      @cochrane.create_suggestion(user: @contributor)
      @red_hair_pirates.create_suggestion(user: @superadmin)
      @roger_pirates.create_suggestion(user: @superadmin)
      @msph.create_suggestion(user: @auditor)
      @jd.create_suggestion(user: @contributor)

      # Degrees-Profiles Associations.
      @bachelor_arts.profiles << @superadmin.profile
      @bachelor_arts.profiles << @contributor.profile
      @bachelor_science.profiles << @auditor.profile
      @master_arts.profiles << @superadmin.profile
      @master_science.profiles << @auditor.profile
      @msph.profiles << @superadmin.profile
      @msph.profiles << @contributor.profile
      @jd.profiles << @auditor.profile
      @msph.profiles << @auditor.profile

      # Frequency.
      Frequency.create([
        { name: 'Daily' },
        { name: 'Weekly' },
        { name: 'Monthly' },
        { name: 'Annually' }
      ])

      # MessageTypes.
      @totd = MessageType.create(name: 'Tip Of The Day', frequency: Frequency.first)
      MessageType.create([
        { name: 'General Announcement', frequency: Frequency.first },
        { name: 'Maintenance Announcement', frequency: Frequency.first }
      ])

      # CitationTypes.
      @primary = CitationType.create(name: 'Primary') 
      @secondary = CitationType.create(name: 'Secondary') 
      @citation_types = [@primary, @secondary]

      # ActionTypes.
      ActionType.create([
        { name: 'Create' },
        { name: 'Destroy' },
        { name: 'Update' }, 
        { name: 'New' },
        { name: 'Index' },
        { name: 'Show' },
        { name: 'Edit' }
      ])

      # TaskTypes.
      @perpetual = TaskType.create(name: 'Perpetual')
      @pilot = TaskType.create(name: 'Pilot')
      @advanced = TaskType.create(name: 'Advanced')
      @task_types = [@perpetual, @pilot, @advanced]

      # ConsensusTypes.
      ConsensusType.create([
        { name: 'Yes' },
        { name: 'No' },
        { name: 'Maybe' },
        { name: 'Conflict' }
      ])

      # Type1Types.
      Type1Type.create([
        { name: 'Categorical' },
        { name: 'Continuous' },
        { name: 'Time to Event' },
        { name: 'Adverse Event' }
      ])

      # Turn on paper_trail.
      PaperTrail.enabled = true

    end
  end
end

module SeedDataExtended
  def self.extended(object)
    object.instance_exec do
      # Turn off paper_trail.
      PaperTrail.enabled = false

      # Projects.
      100.times do |n|
        updated_at = Faker::Time.between(DateTime.now - 1000, DateTime.now - 1)
        Project.create(name:        Faker::Book.unique.title,
                       description: '(' + (n+1).to_s + ') - ' + \
                                    Faker::Lorem.paragraph(20, true),
                       attribution: Faker::Cat.registry,
                       methodology_description: Faker::HarryPotter.quote,
                       prospero:                Faker::Number.hexadecimal(12),
                       doi:                     Faker::Number.hexadecimal(6),
                       notes:                   Faker::HarryPotter.book,
                       funding_source:          Faker::Book.publisher,
                       created_at:              updated_at - rand(1000).hours,
                       updated_at:              updated_at)
        Faker::UniqueGenerator.clear
      end

      # Publishings.
      Project.all.each do |p|
        requested_by = User.offset(rand(User.count)).first
        approved_by = User.offset(rand(User.count)).first
        case rand(10)
        when 0  # Create Publishing object.
          p.request_publishing_by(User.first)
          p.request_publishing_by(User.second)
        when 1  # Create Publishing object.
          p.request_publishing_by(User.first)
          p.request_publishing_by(User.third)
        when 2  # Create Publishing object and approve it.
          Publishing.create(publishable: p, user: requested_by)
                    .approve_by(approved_by)
        end
      end

      # Citations, Journals, Authors and Keywords
      1000.times do |n|
        updated_at = Faker::Time.between(DateTime.now - 1000, DateTime.now - 1)
        c = Citation.create(name:       Faker::Lorem.sentence,
                            pmid:       Faker::Number.number(10),
                            refman:     Faker::Number.number(9),
                            abstract:   Faker::Lorem.paragraph,
                            citation_type:  @citation_types.sample,
                            created_at:     updated_at - rand(1000).hours,
                            updated_at:     updated_at)


        # Journals
        Journal.create(name:              Faker::RockBand.name,
                       publication_date:  Faker::Date.backward(10000),
                       volume:            Faker::Number.number(1),
                       issue:             Faker::Number.number(1),
                       citation:          c)

        # Keywords
        5.times do |n|
          Keyword.create(name:      Faker::Hipster.word,
                         citation:  c)
        end

        # Authors
        5.times do |n|
          Author.create(name:       Faker::HitchhikersGuideToTheGalaxy.character,
                        citation:   c)
        end

      end

      # CitationsProjects
      Project.all.each do |p|
        p.citations = Citation.all.sample(50)
      end

      # Tasks.
      Project.all.each do |p|
        case rand(3)
        when 0
          Task.create(num_assigned: 100,
                      task_type:    @perpetual,
                      project:      p)
        when 1
          pilot_size = rand(100)
          Task.create(num_assigned: pilot_size,
                      task_type:    @pilot,
                      project:      p)
          Task.create(num_assigned: 100 - pilot_size,
                      task_type:    @perpetual,
                      project:      p)

        when 2
          advanced_size = rand(100)
          Task.create(num_assigned: advanced_size,
                      task_type:    @advanced,
                      project:      p)
          Task.create(num_assigned: 100 - advanced_size,
                      task_type:    @advanced,
                      project:      p)
        end
      end

      # Assignments.
      Task.all.each do |t|
        case t.task_type.name
        when 'Perpetual', 'Pilot'
          Assignment.create([{  date_assigned:    DateTime.now,
                                 date_due:         Date.today + 7,
                                 user:             @screener_1,
                                 task:             t },
                              {  date_assigned:    DateTime.now,
                                 date_due:         Date.today + 7,
                                 user:             @screener_2,
                                 task:             t },
                              {  date_assigned:    DateTime.now,
                                 date_due:         Date.today + 7,
                                 user:             @screener_3,
                                 task:             t }])
        when 'Advanced'
          for s in @screeners.sample(rand(3))
            Assignment.create(   date_assigned:    DateTime.now,
                                 date_due:         Date.today + 7,
                                 user:             s,
                                 task:             t)
          end
        end
      end

      # Messages.
      @totd = MessageType.first
      100.times do
        @totd.messages.create(name: Faker::HarryPotter.unique.book,
                              description: Faker::ChuckNorris.unique.fact,
                              start_at: 10.minute.ago)
        Faker::UniqueGenerator.clear
      end

      # Key Questions.
      @kq1 = KeyQuestion.create(name: 'kq1')
      @kq2 = KeyQuestion.create(name: 'kq2')

      # Extraction Form Types.
      @efs_project_type1 = ExtractionFormsProjectType.create(name: 'Standard')
      @efs_project_type2 = ExtractionFormsProjectType.create(name: 'Diagnostic Test')

      # Extraction Forms Projects Section Types.
      ExtractionFormsProjectsSectionType.create(
        [
          { name: 'Type 1' },
          { name: 'Type 2' },
          { name: 'Results' },
          { name: 'Key Questions' }
        ]
      )

      # Sections.
      Section.create(
        [
          { name: 'Key Questions', default: true },
          { name: 'Design Details', default: true },
          { name: 'Arms', default: true },
          { name: 'Arm Details', default: true },
          { name: 'Sample Characteristics', default: true },
          { name: 'Outcomes', default: true },
          { name: 'Outcome Details', default: true },
          { name: 'Quality', default: true },
          { name: 'Results', default: true }
        ]
      )

      # Extraction Forms.
      @ef1 = ExtractionForm.create(name: 'ef1')
      @ef2 = ExtractionForm.create(name: 'ef2')

      # Associate KQ's and EF's with first project.
      @project = Project.order(updated_at: :desc).first
      @project.key_questions << [@kq1, @kq2]
      @project.extraction_forms_projects.create!(extraction_form: @ef1, extraction_forms_project_type: @efs_project_type1)
      @project.extraction_forms_projects.create!(extraction_form: @ef2, extraction_forms_project_type: @efs_project_type1)

      # Seed QuestionRowColumnFieldType.
      QuestionRowColumnFieldType.create(
        [
          { name: 'text' },
          { name: 'numeric' },
          { name: 'numeric_range' },
          { name: 'scientific' },
          { name: 'checkbox' },
          { name: 'dropdown' },
          { name: 'radio' },
          { name: 'select2_single' },
          { name: 'select2_multi' }
        ]
      )

      # Seed QuestionRowColumnFieldOption.
      QuestionRowColumnFieldOption.create(
        [
          { name: 'answer_choice' }, # For multiple-choice: checkbox, radio, dropdown
          { name: 'min_length' },    # For text
          { name: 'max_length' },    # For text
          { name: 'min_value' },     # For scientific, numerical
          { name: 'max_value' },     # For scientific, numerical
          { name: 'coefficient' },   # For scientific
          { name: 'exponent' }       # For scientific
        ]
      )

      # Seed ProjectsUser.
      @project.users << @contributor

      # Seed ProjectsUsersRole.
      ProjectsUser.find_by(project: @project, user: @contributor).roles << Role.where(name: 'Leader')

      # Turn on paper_trail.
      PaperTrail.enabled = true
    end
  end
end
