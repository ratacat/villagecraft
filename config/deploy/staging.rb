set :domain, 'test.villagecraft.org'
# UNTESTED the following should exclude .conf files to avoid sending prodcution configurations to staging server
set :copy_exclude, [".git/", "config/*.conf"]
server 'test.villagecraft.org', :app, :web, :db, :primary => true


# task :mirror_db_from_live_server do 
# 	run 'ssh villagecraft@villagecraft.org "pg_dump -c villagecraft_production" | psql villagecraft_production'
# end

