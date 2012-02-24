require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :deploy do
    desc 'Restarting Passenger with restart.txt'
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "touch #{current_path}/tmp/restart.txt"
    end

    [ :start, :stop ].each do |t|
      desc "#{t} task is a no-op with Passenger"
      task t, :roles => :app do ; end
    end
  end
end

