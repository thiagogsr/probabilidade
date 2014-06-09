require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
# require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application, 'probabilidade'
set :domain, '50.116.27.37'
set :port, 1500
set :user, 'deploy'
set :deploy_to, '/var/www/probabilidade'
set :current_path, "#{deploy_to}/current"
set :repository, 'git@github.com:thiagogsr/probabilidade.git'
set :branch, 'master'
set :pid, "#{deploy_to}/tmp/pids/#{application}.pid"

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
# set :shared_paths, ['config/database.yml', 'log']
set :shared_paths, ['log']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/tmp/pids"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    to :launch do
      invoke :'rackup:restart'
    end
  end
end

namespace :rackup do
  desc "Start the application '#{application}' services"
  task :start do
    queue! "cd #{current_path}; RAILS_ENV=production bundle exec rackup -E production -D -p 4567 -P #{pid}"
  end

  desc "Stop the application '#{application}' services"
  task :stop do
    queue! "cd #{current_path}; if [ -f #{pid} ] && [ -e /proc/$(cat #{pid}) ]; then kill -9 `cat #{pid}`; fi"
  end
 
  desc "Restart the application '#{application}' services"
  task :restart do
    invoke 'rackup:stop'
    invoke 'rackup:start'
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers