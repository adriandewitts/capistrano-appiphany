require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :passenger do
    desc 'Start a Passenger Standalone instance'
    task :start do
      run "cd #{current_path} && RBENV_VERSION=#{rbenv_version} passenger start -a127.0.0.1 -p#{passenger_port} -e production -d"
    end

    desc 'Stop a Passenger Standalone instance'
    task :stop do
      run "cd #{current_path} && RBENV_VERSION=#{rbenv_version} passenger stop -p#{passenger_port} || true"
    end

    desc 'Restart a Passenger Standalone instance'
    task :restart do
      stop
      start
    end

    desc 'Configure init.d script from config/deploy/passenger-init.d'
    task :initd do
      sudo "ln -nfs #{current_path}/config/deploy/passenger-init.d /etc/init.d/#{application} && chmod +x /etc/init.d/#{application}"
      sudo "update-rc.d #{application} defaults"
    end
  end

  namespace :deploy do
    desc 'Restarting mod_rails with restart.txt'
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "touch #{current_path}/tmp/restart.txt"
    end

    [:start, :stop].each do |t|
      desc "#{t} task is a no-op with mod_rails"
      task t, :roles => :app do ; end
    end
  end
end

