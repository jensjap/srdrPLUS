module SeedData
  def self.extended(object)
    object.instance_exec do
      ## Turn off paper_trail.
      PaperTrail.enabled = false

      ## Initialize first accounts:
      @test_superadmin = User.create do |u|
        u.email        = 'test_superadmin@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @test_contributor = User.create do |u|
        u.email        = 'test_contributor@test.com'
        u.password     = 'password'
        u.confirmed_at = Time.now()
      end

      @test_auditor = User.create do |u|
        u.email        = 'test_auditor@test.com'
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

      @cochrane = Organization.create(name: 'Cochrane')
      @red_hair_pirates = Organization.create(name: 'Red Hair Pirates')
      @straw_hat_pirates = Organization.create(name: 'Straw Hat Pirates')
      @roger_pirates = Organization.create(name: 'Roger Pirates')

      @bachelor_arts = Degree.create(name: 'Bachelor of Arts - BA')
      @bachelor_science = Degree.create(name: 'Bachelor of Science - BS')
      @master_arts = Degree.create(name: 'Master of Arts - MA')
      @master_science = Degree.create(name: 'Master of Science - MS')
      @msph = Degree.create(name: 'Master of Science in Public Health - MSPH')
      @jd = Degree.create(name: 'Juris Doctor - JD')
      @md = Degree.create(name: 'Medical Doctor - MD')
      @phd = Degree.create(name: 'Doctor of Philosophy - PhD')

      @cochrane.create_suggestion(user: @test_contributor)
      @red_hair_pirates.create_suggestion(user: @test_superadmin)
      @roger_pirates.create_suggestion(user: @test_superadmin)
      @msph.create_suggestion(user: @test_auditor)
      @jd.create_suggestion(user: @test_contributor)

      @superadmin_profile = Profile.create(user: @test_superadmin,
                                           organization: @red_hair_pirates,
                                           username: 'test_superadmin',
                                           first_name: 'Red',
                                           middle_name: 'Haired',
                                           last_name: 'Shanks')
      @contributor_profile = Profile.create(user: @test_contributor,
                                            organization: @straw_hat_pirates,
                                            username: 'test_contributor',
                                            first_name: 'Monkey',
                                            middle_name: 'D',
                                            last_name: 'Luffy')
      @auditor_profile = Profile.create(user: @test_auditor,
                                        organization: @straw_hat_pirates,
                                        username: 'test_auditor',
                                        first_name: 'Nico',
                                        middle_name: '',
                                        last_name: 'Robin')
      @public_profile = Profile.create(user: @test_public,
                                       organization: @roger_pirates,
                                       username: 'test_public',
                                       first_name: 'Gol',
                                       middle_name: 'D',
                                       last_name: 'Roger')

      @bachelor_arts.profiles << @superadmin_profile
      @bachelor_arts.profiles << @contributor_profile
      @bachelor_science.profiles << @auditor_profile
      @master_arts.profiles << @superadmin_profile
      @master_science.profiles << @auditor_profile
      @msph.profiles << @superadmin_profile
      @msph.profiles << @contributor_profile
      @jd.profiles << @auditor_profile
      @msph.profiles << @auditor_profile

      99.times do |n|
        Project.create!(name:        Faker::Book.unique.title,
                        description: Faker::ChuckNorris.fact,
                        attribution: Faker::Cat.registry,
                        methodology_description: Faker::RuPaul.quote,
                        prospero:                Faker::Number.hexadecimal(12),
                        doi:                     Faker::Number.hexadecimal(6),
                        notes:                   Faker::Lorem.sentences(1),
                        funding_source:          Faker::Book.publisher)
      end

      ## Turn on paper_trail.
      PaperTrail.enabled = true

    end
  end
end
