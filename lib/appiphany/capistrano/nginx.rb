require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :nginx do
    desc 'Configure with deploy/nginx file'
    task :configure, :roles => :app, :except => { :no_release => true } do
      run "#{sudo} ln -nfs #{current_path}/config/nginx /etc/nginx/sites-enabled/#{application}"
    end

    [ :start, :stop ].each do |t|
      desc "#{t} task is a no-op with Passenger"
      task t, :roles => :app do ; end
    end
  end

  after 'deploy:setup', 'nginx:configure'
end

