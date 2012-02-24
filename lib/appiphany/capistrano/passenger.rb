require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :passenger do
    desc 'Trigger compilation'
    task :compile do
      run "cd #{current_path} && bundle exec passenger start -d -p 3123 --pid-file #{current_path}/tmp/passenger.install.pid"
      sleep 3 # Give it 3 seconds to start
      run "kill `cat #{current_path}/tmp/passenger.install.pid`"
    end
  end

  namespace :deploy do
    desc 'Restarting Passenger with restart.txt'
    task :restart do
      run "touch #{current_path}/tmp/restart.txt"
    end

    after 'deploy' do
      releases = capture("ls -l #{release_path}/..").split("\n").size - 1
      passenger.compile if releases == 1
    end

    [ :start, :stop ].each do |t|
      desc "#{t} task is a no-op with Passenger"
      task t, :roles => :app do ; end
    end
  end
end

