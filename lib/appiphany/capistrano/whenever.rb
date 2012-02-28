require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :whenever do
    task :update_crontab do
      run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
    end
  end

  before 'deploy:restart', 'whenever:update_crontab'
end

