# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

## Initialize first account:
test_user = User.create! do |u|
  u.email    = 'test@test.com'
  u.password = 'password'
end

organizations = Organization.create([
  { name: '-- Unspecified --' },
  { name: 'Brown University' },
  { name: 'Johns Hopkins University' },
  { name: 'Cochrane' }
])

titles = Title.create([
  { name: '-- Unspecified --' },
  { name: 'Mr.' },
  { name: 'Ms.' },
  { name: 'Mrs.' },
  { name: 'Sir' },
  { name: 'Lady' },
  { name: 'Dr.' }
])

UserDetail.create(
  user: test_user,
  organization: organizations.first,
  username: 'tester',
  title: titles.first,
  first_name: 'Monkey',
  middle_name: 'D',
  last_name: 'Luffy'
)
