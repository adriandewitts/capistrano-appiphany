require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :deploy do
    desc 'Use god to restart the service'
    task :restart do
      run "#{sudo} -i god restart #{application}-passenger"
    end

    task :start do
      run "#{sudo} -i god start #{application}-passenger"
    end

    task :stop do
      run "#{sudo} -i god stop #{application}-passenger"
    end
  end
end

