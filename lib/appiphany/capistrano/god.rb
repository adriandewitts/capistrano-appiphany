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
    task :quit do
      sudo 'stop god; true'
    end

    task :start do
      sudo 'start god'
    end

    task :restart_all do
      god_cmd "restart #{application} || sleep 10; restart #{application}"
    end

    task :restart do
      if ENV['SERVICE']
        god_cmd "restart #{ENV['SERVICE']}"
      else
        raise "Specify SERVICE=name to restart"
      end
    end
  end

  after 'deploy' do
    sudo "ln -nfs #{current_path}/config/deploy/#{application}.god /etc/god/config.d/#{application}.god"
    god.quit
    god.start
    god.restart_all
  end
end

