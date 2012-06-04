## Recipes for deploying Appiphany apps.

There are several recipes for each part of the app. First add this gem to the `Gemfile` and then to the `deploy.rb` file like so:

```ruby
require 'appiphany/capistrano/base' # Always start with this one
require 'appiphany/capistrano/LIBRARY'
```

Available libraries are after the "Base recipes" below.

### Base recipes

This is the default configuration:

```ruby
  default_environment['PATH'] = '/opt/rbenv/shims:/opt/rbenv/bin:$PATH'

  set :use_sudo, false

  set :scm, 'git'

  set(:appdir)     { "/home/#{user}/#{application}" }
  set :branch,     'master'
  set :deploy_via, 'remote_cache'

  set(:deploy_to) { appdir }

  default_run_options[:pty]   = true
  ssh_options[:forward_agent] = true
```

All of these can be overriden in the `deploy.rb` file.

If the remote file `#{shared_path}/config/database.yml` exists, then it will be linked to
`#{release_path}/config/database.yml` after updating the code.

After `deploy:setup` the following actions will be performed:

* Create `#{shared_path}/config`
* Link the `log` directory to the main log directory on `/home/#{user}/logs/#{application}
* If a `config/database.example.yml` exists, you will be prompted for values to create a real production `database.yml` file.

#### Usign rbenv

If a `.rbenv_version` file exists in the app's root, it will be linked inside the `/home/#{user}/#{application}` directory
so when you SSH into the server, all the commands run in that tree use the proper Ruby version.

### God (`god`)

God is used to manage services used by an app, including the web server.

* `god:quit` stops the god daemon without stopping any monitored services.
* `god:start` starts the god daemon and starts services as needed.
* `god:restart_all` restarts all of the apps services.
* `god:restart SERVICE=name` restarts just the named service.

An app's god config file lives in `config/deploy/#{application}.god`. This file will be linked to
`/etc/god/config.d/#{application}.god` so the daemon picks up the configuration.

After a deploy, the god daemon will be restarted (so it picks up any changes in the config file), and then all
the app's services will be restarted.

Here's a template for the config file with example monitors for the web server, sphinx, and resque:

```ruby
app = 'APP_NAME'

default = DefaultConfig.new(root: "/home/ubuntu/#{app}")

God.watch do |w|
  name = app + '-web'

  default.with(w, name: name, group: app)

  w.start    = default.bundle_cmd "passenger start -d -S /tmp/#{app}-passenger.sock -e production"
  w.pid_file = "#{default[:root]}/shared/pids/passenger.pid"
end

God.watch do |w|
  name = app + '-sphinx'

  default.with(w, name: name, group: app)

  w.start    = default.bundle_cmd 'rake ts:start'
  w.pid_file = "#{default[:root]}/shared/log/searchd.#{default[:rails_env]}.pid"
  w.log      = "#{default[:root]}/shared/log/god-sphinx.log"
end

God.watch do |w|
  name = app + '-worker'

  default.with(w, name: name, group: app, env: { 'QUEUE' => app })

  w.start = default.bundle_cmd 'rake environment resque:work'
  w.log   = "#{default[:root]}/shared/log/god-worker.log"
end
```
