# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

## Turn off paper_trail.
PaperTrail.enabled = false

## Initialize first accounts:
test_superadmin = User.create! do |u|
  u.email        = 'test_superadmin@test.com'
  u.password     = 'password'
  u.confirmed_at = Time.now()
end

test_contributor = User.create! do |u|
  u.email        = 'test_contributor@test.com'
  u.password     = 'password'
  u.confirmed_at = Time.now()
end

test_auditor = User.create! do |u|
  u.email        = 'test_auditor@test.com'
  u.password     = 'password'
  u.confirmed_at = Time.now()
end

test_guest = User.create! do |u|
  u.email        = 'test_guest@test.com'
  u.password     = 'password'
  u.confirmed_at = Time.now()
end

organizations = Organization.create!([
  { name: '-- Unspecified --' },
  { name: 'Brown University' },
  { name: 'Johns Hopkins University' },
  { name: 'Cochrane' },
  { name: 'Red Hair Pirates' },
  { name: 'Straw Hat Pirates' },
  { name: 'Roger Pirates' }
])

degrees = Degree.create!([
  { name: '-- Unspecified --' },
  { name: 'BA.' }, { name: 'BS.' },
  { name: 'MA.' }, { name: 'MS.' },
  { name: 'MPH.' }, { name: 'J.D.' },
  { name: 'M.D.' }, { name: 'Ph.D.' }
])

Profile.create!([
  { user: test_superadmin, organization: Organization.find_by(name: 'Red Hair Pirates'),
    username: 'test_superadmin', first_name: 'Red', middle_name: 'Haired', last_name: 'Shanks' },
  { user: test_contributor, organization: Organization.find_by(name: 'Straw Hat Pirates'),
    username: 'test_contributor', first_name: 'Monkey', middle_name: 'D', last_name: 'Luffy' },
  { user: test_auditor, organization: Organization.find_by(name: 'Straw Hat Pirates'),
    username: 'test_auditor', first_name: 'Nico', middle_name: '', last_name: 'Robin' },
  { user: test_guest, organization: Organization.find_by(name: 'Roger Pirates'),
    username: 'test_guest', first_name: 'Gol', middle_name: 'D', last_name: 'Roger' }
])

Profile.find(1).degrees << Degree.find(2)
Profile.find(1).degrees << Degree.find(5)
Profile.find(2).degrees << Degree.find(2)
Profile.find(3).degrees << Degree.find(3)
Profile.find(3).degrees << Degree.find(6)
Profile.find(4).degrees << Degree.find(2)
Profile.find(4).degrees << Degree.find(5)
Profile.find(4).degrees << Degree.find(7)

## Turn on paper_trail.
PaperTrail.enabled = true
