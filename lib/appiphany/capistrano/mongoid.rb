require 'appiphany/capistrano/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
  namespace :mongoid do
    task :symlink do
      sudo "ln -sf #{shared_path}/config/mongoid.yml #{current_path}/config/mongoid.yml"
    end
  end
end

