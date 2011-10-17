require 'capistrano/appiphany/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  _cset :use_sudo,      false

  # SCM settings
  _cset(:appdir)     { "/home/#{user}/#{application}" }
  _cset :scm,        'git'
  _cset :branch,     'master'
  _cset :deploy_via, 'remote_cache'

  set(:deploy_to)  { appdir }

  # Git settings for capistrano
  default_run_options[:pty]   = true # needed for git password prompts
  ssh_options[:forward_agent] = true # use the keys for the person running the cap command to check out the app

  namespace :app do
    desc 'Update the crontab file (Whenever)'
    task :update_crontab do
      run "cd #{current_path} && bundle exec whenever --update-crontab #{application}"
    end

    desc 'Create app symlinks (database.yml...)'
    task :symlinks do
      run <<-CMD
        ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml
      CMD
    end
  end

  after 'deploy:update_code', 'app:symlinks'
end

