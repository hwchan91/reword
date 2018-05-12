namespace :users do
  desc "Delete inactive users"
  task :destroy_inactive => :environment do
    User.where(completed_levels: []).destroy_all
    puts "Inactive users destroyed"
  end
end
