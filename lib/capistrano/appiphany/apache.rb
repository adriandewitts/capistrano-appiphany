require 'capistrano/appiphany/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :apache do
    task :reload do
      sudo 'apache2ctl graceful'
    end

    task :start do
      sudo 'a2ensite #{application}'
      apache.reload
    end

    task :stop do
      sudo 'a2dissite #{application}'
      apache.reload
    end

    task :restart do
      apache.start
      run 'touch #{current_path}/tmp/restart.txt'
    end

    task :configure do
      sudo "ln -sf #{current_path}/config/deploy/apache_vhost.conf /etc/apache2/sites-available/#{application}"
    end
  end
end

