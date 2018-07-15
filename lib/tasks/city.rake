namespace :city do
  desc "Refresh the festivals"
  task update_festivals: :environment do
    RefreshFestivalsJob.perform_later
  end
end
