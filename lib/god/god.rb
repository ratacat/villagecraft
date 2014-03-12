# Some notes because this was a pain to setup.
#
# On CentOS 6.4 (our box) and other linuxes, you must first install Netlink headers and libraries:
# sudo yum install libnl libnl-devel
# 
# And, quite annoyingly, run god as root.  
#
# Since we use rbenv, this requires using the rbenv sudo plugin (https://github.com/dcarley/rbenv-sudo):
# git clone git://github.com/dcarley/rbenv-sudo.git ~/.rbenv/plugins/rbenv-sudo
#
# Once that's all set up, you can do:
# rbenv sudo god -c lib/god/god.rb

God::Contacts::Email.defaults do |d|
  d.from_email = 'notifications@villagecraft.org'
  d.from_name = 'God'
  d.delivery_method = :sendmail
  d.server_host = 'smtp.sendgrid.net'
  d.server_port = 587
  d.server_auth = true
  d.server_user = 'Jared Smith'
  d.server_password = 'slack3r101'
end

God.contact(:email) do |c|
  c.name = 'ben'
  c.group = 'developers'
  c.to_email = 'ben@teitelbaum.us'
end

RAILS_ROOT = "/home/villagecraft/www/current"

God.watch do |w|
  w.name = "notifier.rb"

  w.start = "su - villagecraft -c 'cd #{RAILS_ROOT}; bundle exec rake daemon:notifier:start'"
  w.stop = "su - villagecraft -c 'cd #{RAILS_ROOT}; bundle exec rake daemon:notifier:stop'"
  w.restart = "su - villagecraft -c 'cd #{RAILS_ROOT}; bundle exec rake daemon:notifier:restart'"

  w.pid_file = File.join(RAILS_ROOT, "log/notifier.rb.pid")

  w.interval = 10.seconds  # default

  # clean pid files before start if necessary
  w.behavior(:clean_pid_file)

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_exits) do |c|
      c.notify = 'ben'
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end