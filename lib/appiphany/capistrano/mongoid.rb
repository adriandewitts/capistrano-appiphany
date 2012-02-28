require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :mongoid do
    task :symlink do
      sudo "ln -sf #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    end
  end

  after 'deploy:update_code', 'mongoid:symlink'
end

