require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  default_environment['PATH'] = '$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH'
  default_environment['RBENV_VERSION'] = rbenv_version if exists?(:rbenv_version)

  _cset :use_sudo, false

  # SCM settings
  set :scm, 'git'

  _cset(:appdir)     { "/home/#{user}/#{application}" }
  _cset :branch,     'master'
  _cset :deploy_via, 'remote_cache'

  set(:deploy_to) { appdir }

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

  namespace :db do
    desc 'Create database.yml config file'
    task :configure do
      template = <<CONFIG
%ENV%:
  adapter: %ADAPTER%
  encoding: %ENCODING%
  reconnect: %RECONNECT%
  pool: %POOL%
  host: %HOST%
  database: %DATABASE%
  username: %USERNAME%
  password: %PASSWORD%
CONFIG

      hl = Capistrano::CLI.ui
      hl.say 'Configure the database.yml file'

      begin
        template.gsub! '%ENV%', (hl.ask('Environment:') { |q| q.default = 'production' })
        template.gsub! '%ADAPTER%', hl.ask('Adapter (mysql|mysql2|pg):')
        template.gsub! '%ENCODING%', (hl.ask('Encoding:') { |q| q.default = 'utf8' })
        template.gsub! '%RECONNECT%', (hl.ask('Reconnect:') { |q| q.default = 'false' })
        template.gsub! '%POOL%', (hl.ask('Pool:') { |q| q.default = '5' })
        template.gsub! '%HOST%', hl.ask('Host:')
        template.gsub! '%DATABASE%', hl.ask('Database:') { |q| q.default = application }
        template.gsub! '%USERNAME%', hl.ask('Username:')
        template.gsub! '%PASSWORD%', hl.ask('Password:')
        puts template
      end while hl.ask('Is this ok? (y/n)').downcase != 'y'

      put template, "#{shared_path}/config/database.yml"
    end
  end

  after 'deploy:update_code', 'app:symlinks'
  after('deploy:setup') do
    run "mkdir -p #{shared_path}/config"
    location = "/home/#{user}/logs/#{application}"
    run "rmdir #{shared_path}/log && mkdir -p #{location} && ln -s #{location} #{shared_path}/log"

    if File.exists?(File.join(rails_root, 'config/database.yml.example'))
      db.configure
    end
  end
end

