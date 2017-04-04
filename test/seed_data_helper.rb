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
        { name: 'Brown University', suggested: false },
        { name: 'Johns Hopkins University', suggested: false },
        { name: 'Cochrane', suggested: false }
      ])

      @red_hair_pirates = Organization.create(name: 'Red Hair Pirates', suggested: false)
      @straw_hat_pirates = Organization.create(name: 'Straw Hat Pirates', suggested: false)
      @roger_pirates = Organization.create(name: 'Roger Pirates', suggested: false)

      @degrees = Degree.create([
        { name: 'Bachelor of Arts - BA' },
        { name: 'Bachelor of Science - BS' },
        { name: 'Master of Arts - MA' },
        { name: 'Master of Science - MS' },
        { name: 'Master of Science in Public Health - MSPH' },
        { name: 'Juris Doctor - JD' },
        { name: 'Medical Doctor - MD' },
        { name: 'Doctor of Philosophy - PhD' }
      ])

      @bachelor = Degree.find_by(name: 'Bachelor of Arts - BA')
      @master = Degree.find_by(name: 'Bachelor of Science - BS')
      @msph = Degree.find_by(name: 'Master of Science in Public Health - MSPH')
      @jd = Degree.find_by(name: 'Juris Doctor - JD')
      @md = Degree.find_by(name: 'Medical Doctor - MD')
      @phd = Degree.find_by(name: 'Doctor of Philosophy - PhD')

      Profile.create([
      ])

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

      @bachelor.profiles << @superadmin_profile
      @bachelor.profiles << @contributor_profile
      @bachelor.profiles << @auditor_profile
      @master.profiles << @superadmin_profile
      @master.profiles << @auditor_profile
      @msph.profiles << @superadmin_profile
      @msph.profiles << @contributor_profile
      @jd.profiles << @auditor_profile
      @msph.profiles << @auditor_profile

      ## Turn on paper_trail.
      PaperTrail.enabled = true

    end
  end
end
