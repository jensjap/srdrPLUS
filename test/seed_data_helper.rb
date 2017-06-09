module SeedData
  def self.extended(object)
    object.instance_exec do
      # Turn off paper_trail.
      PaperTrail.enabled = false

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
      1000.times do |n|
        updated_at = Faker::Time.between(DateTime.now - 1000, DateTime.now)
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
          { name: 'Type 3' },
          { name: 'Key Questions' }
        ]
      )

      # Extraction Forms.
      @ef1 = ExtractionForm.create(name: 'ef1')
      @ef2 = ExtractionForm.create(name: 'ef2')

      # Associate KQ's and EF's with first project.
      @project = Project.order(updated_at: :desc).first
      @project.key_questions << [@kq1, @kq2]
      @project.extraction_forms << [@ef1, @ef2]

      # Seed QuestionType.
      QuestionType.create(
        [
          { name: 'Text' },
          { name: 'Checkbox' },
          { name: 'Dropdown' },
          { name: 'Radio' },
          { name: 'Matrix Checkbox' },
          { name: 'Matrix Dropdown' },
          { name: 'Matrix Radio' }
        ]
      )

      # Turn on paper_trail.
      PaperTrail.enabled = true
    end
  end
end
