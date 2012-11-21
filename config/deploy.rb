set :application, "friendwatcher"
set :repository,  "ssh://git@bitbucket.org/jhester/friendwatcher-rails.git"
set :user, "jonathan"

set :deploy_to, "/var/www/friendwatcher"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "jonathanhester.com"                          # Your HTTP server, Apache/etc
role :app, "jonathanhester.com"                          # This may be the same as your `Web` server
role :db,  "jonathanhester.com", :primary => true # This is where Rails migrations will run

set :rvm_ruby_string, 'ruby-1.9.2-p318@friendwatcher'
require "rvm/capistrano"

set :rvm_type, :system  # Copy the exact line. I really mean :system here

before 'deploy:setup', 'rvm:install_rvm'

before 'deploy:setup', 'rvm:install_ruby'

set :rvm_install_ruby_params, '--with-opt-dir=/usr/local/rvm/usr'
before 'deploy:setup', 'rvm:install_pkgs'

before 'deploy:setup', 'rvm:import_gemset'

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end