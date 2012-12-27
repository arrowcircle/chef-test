require "bundler/capistrano"

set :application, "chef-test"
set :repository,  "git://github.com/arrowcircle/chef-test.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "192.168.2.160"                          # Your HTTP server, Apache/etc
role :app, "192.168.2.160"                          # This may be the same as your `Web` server
role :db,  "192.168.2.160", :primary => true # This is where Rails migrations will run
role :db,  "192.168.2.160"

set :user, "webmaster"
set :deploy_to, "/home/#{user}/projects/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do
    run "sudo service #{application} start"
  end
  task :stop do
    run "sudo service #{application} stop"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "sudo service #{application} restart"
  end
end
namespace :uploads do
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "rm -Rf #{release_path}/public/uploads"
    run "ln -s #{shared_path}/uploads #{release_path}/public/uploads"
  end
end
after "deploy:finalize_update", "uploads:symlink"