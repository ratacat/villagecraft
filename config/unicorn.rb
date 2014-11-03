# Our own variable where we deploy this app to
deploy_to = "/home/villagecraft/www"

current_path = "#{deploy_to}/current"
shared_path = "#{deploy_to}/shared"

# Set unicorn options

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes 4
preload_app true

# nuke workers after X seconds instead of (60 seconds default)
timeout 180

# feel free to point this anywhere accessible on the filesystem
pid "#{shared_path}/pids/unicorn.pid"

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "#{shared_path}/sockets/unicorn.sock", :backlog => 64
# listen 9090, :tcp_nopush => true, :tries => -1

# Spawn unicorn master worker for user apps (group: apps)
# user 'apps', 'apps' 

# Fill path to your app
working_directory current_path

# Should be 'production' by default, otherwise use other env 
rails_env = ENV['RAILS_ENV'] || 'production'

# some applications/frameworks log to stderr or stdout, so prevent
# them from going to /dev/null when daemonized here and log everything to one file
stderr_path "#{shared_path}/log/unicorn.log"
stdout_path "#{shared_path}/log/unicorn.log"

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end