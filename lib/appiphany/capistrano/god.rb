require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

def god_cmd(cmd)
  rbenv_version = capture('cat /opt/rbenv/version').strip
  run "#{sudo} -i RBENV_VERSION=#{rbenv_version} god #{cmd}"
end

configuration.load do
  namespace :god do
    # These tasks first 'cd' so we go out of the current dir and the default rbenv version is used

    task :quit do
      sudo 'stop god; true'
    end

    task :start do
      sudo 'start god'
    end

    task :restart_all do
      god_cmd "restart #{application};true"
    end
  end

  after 'deploy' do
    sudo "ln -nfs #{current_path}/config/deploy/#{application}.god /etc/god/config.d/#{application}.god"
    god.quit
    god.start
    god.restart_all
  end
end

