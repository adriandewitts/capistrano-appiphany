require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  _cset :ts_rebuild_on_deploy, true

  namespace :ts do
    desc 'Stop the sphinx server'
    task :stop , :roles => :app do
      run "cd #{current_path} && bundle exec rake thinking_sphinx:stop RAILS_ENV=production"
    end

    desc 'Start the sphinx server'
    task :start, :roles => :app do
      run "cd #{current_path} && bundle exec rake thinking_sphinx:configure RAILS_ENV=production && bundle exec rake thinking_sphinx:start RAILS_ENV=production"
    end

    desc 'Restart the sphinx server'
    task :restart_sphinx, :roles => :app do
      stop
      start
    end

    desc 'Rebuild the sphinx server'
    task :rebuild, :roles => :app do
      run "cd #{current_path} && bundle exec rake thinking_sphinx:rebuild RAILS_ENV=production"
    end

    desc 'Re-establish symlinks'
    task :symlink_db do
      run <<-CMD
        mkdir -p #{shared_path}/db/sphinx &&
        rm -rf #{release_path}/db/sphinx &&
        ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx
      CMD
    end
  end

  after 'deploy:symlink', 'ts:symlink_db'
  after 'deploy:symlink' do
    ts.rebuild if ts_rebuild_on_deploy
  end
end

