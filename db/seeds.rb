# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
['admin', 'registered', 'trainer'].each do |role|
  Role.find_or_create_by_name(role)
end
if User.all.size == 0 then
  admin = User.new(:email => 'example@email.com', :password => 'secret', :password_confirmation => 'secret', :full_name => 'My admin')
  admin.role = Role.find_by_name('admin')
  admin.save!
end