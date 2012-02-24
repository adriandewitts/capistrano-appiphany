require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :nginx do
    desc 'Configure with deploy/nginx file'
    task :configure, :roles => :app, :except => { :no_release => true } do
      run "#{sudo} ln -nfs #{current_path}/config/deploy/nginx /etc/nginx/sites-available/#{application}"
    end

    desc 'Enable site'
    task :enable do
      run "#{sudo} ln -nfs /etc/nginx/sites-available/#{application} /etc/nginx/sites-enabled/#{application}"
      nginx.reload
    end

    desc 'Disable site'
    task :disable do
      run "#{sudo} rm -f /etc/nginx/sites-enabled/#{application}"
      nginx.reload
    end

    desc 'Reload configuration'
    task :reload do
      run "#{sudo} /etc/init.d/nginx reload"
    end

    [ :start, :stop ].each do |t|
      desc "#{t} task is a no-op with Passenger"
      task t, :roles => :app do ; end
    end
  end

  after 'deploy:setup', 'nginx:configure'
end

