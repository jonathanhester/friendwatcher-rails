set :application, "friendwatcher"
set :repository,  "ssh://git@bitbucket.org/jhester/friendwatcher-rails.git"
set :user, "jonathan"

set :deploy_to, "/var/www/friendwatcher"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "jonathanhester.com"                          # Your HTTP server, Apache/etc
role :app, "jonathanhester.com"                          # This may be the same as your `Web` server
role :db,  "jonathanhester.com", :primary => true # This is where Rails migrations will run

set :rvm_ruby_string, 'ruby-1.9.3-p327@friendwatcher'
require "rvm/capistrano"

set :rvm_type, :system  # Copy the exact line. I really mean :system here

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

after "deploy", "rvm:trust_rvmrc"

before "deploy:update_code", "toldo:compress_assets"
after "deploy:symlink", "toldo:upload_assets"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do

    end
  end
end


namespace :toldo do
  desc "Compress assets in a local file"
  task :compress_assets do
    run_locally("rm -rf public/assets/*")
    run_locally("bundle exec rake assets:precompile")
    run_locally("touch assets.tgz && rm assets.tgz")
    run_locally("tar zcvf assets.tgz public/assets/")
    run_locally("mv assets.tgz public/assets/")
  end

  desc "Upload assets"
  task :upload_assets do
    upload("public/assets/assets.tgz", release_path + '/assets.tgz')
    run "cd #{release_path}; tar zxvfm assets.tgz; rm assets.tgz"
  end
end

require "delayed/recipes"

set :rails_env, "production" #added for delayed job

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"


namespace :deploy do
  desc "Start the Thin processes"
  task :start do
    run  <<-CMD
      /etc/init.d/thin start
    CMD
  end

  desc "Stop the Thin processes"
  task :stop do
    run <<-CMD
      /etc/init.d/thin stop
    CMD
  end

  desc "Restart the Thin processes"
  task :restart do
    run <<-CMD
      /etc/init.d/thin restart
    CMD
  end
end
