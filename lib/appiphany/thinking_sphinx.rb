require 'capistrano/appiphany/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :ts do
    desc 'Stop the sphinx server'
    task :stop_sphinx , :roles => :app do
      run "cd #{current_path} && bundle exec rake thinking_sphinx:stop RAILS_ENV=production"
    end

    desc 'Start the sphinx server'
    task :start_sphinx, :roles => :app do
      run "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=production && rake thinking_sphinx:start RAILS_ENV=production"
    end

    desc 'Restart the sphinx server'
    task :restart_sphinx, :roles => :app do
      stop_sphinx
      start_sphinx
    end

    desc 'Rebuild the sphinx server'
    task :rebuild_sphinx, :roles => :app do
      run "cd #{current_path} && rake thinking_sphinx:rebuild RAILS_ENV=production"
    end
  end
end

