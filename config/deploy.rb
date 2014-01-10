require 'bundler/capistrano'
require 'capistrano-unicorn'

set :application, 'villagecraft'
set :git_user, 'ratacat'
set :repository,  "git@github.com:#{git_user}/#{application}.git"

set :domain, 'villagecraft.org'
set :deploy_to, '/home/villagecraft/www'
# set :deploy_to, "/home/#{application}/www"

# set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"
set :default_environment, {
  'PATH' => "/home/villagecraft/.rbenv/shims:/home/#{application}/.rbenv/bin:$PATH"
}

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :scm, :git
set :branch, 'master'
set :use_sudo, false
set :scm_verbose, true  

set :user, "villagecraft"

namespace :daemons do
  desc "Start Rails daemons"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; bundle exec script/daemons start"
  end

  desc "Stop Rails daemons"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; bundle exec script/daemons stop"
  end
  
  desc "Restart Rails daemons"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; bundle exec script/daemons restart"
  end
end

namespace :nginx do
  desc "Restart nginx"
  task :restart do
    sudo "/sbin/service nginx reload"
  end
end

namespace :deploy do
  desc "build missing paperclip styles"
  task :build_missing_paperclip_styles, :roles => :app do
    run "cd #{release_path}; RAILS_ENV=production bundle exec rake paperclip:refresh:missing_styles"
  end
end

after("deploy:update_code", "deploy:build_missing_paperclip_styles")
after 'deploy:restart', 'deploy:migrate', 'unicorn:duplicate' # before_fork hook implemented (zero downtime deployments)

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end