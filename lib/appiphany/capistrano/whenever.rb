require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :whenever do
    task :update_crontab do
      if File.exists?("config/schedule.#{stage}.rb")
        run "cd #{current_path} && bundle exec whenever --load-file config/schedule.#{stage}.rb --update-crontab #{application}"
      else
        run "cd #{current_path} && bundle exec whenever --update-crontab #{application}"
      end
    end
  end

  before 'deploy:restart', 'whenever:update_crontab'
end

