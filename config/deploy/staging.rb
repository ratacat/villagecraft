set :rails_env, 'staging'
set :domain, 'test.villagecraft.org'
set :copy_exclude, [".git/", "config/*.conf"]
server 'test.villagecraft.org', :app, :web, :db, :primary => true


# task :mirror_db_from_live_server do 
# 	run 'ssh villagecraft@villagecraft.org "pg_dump -c villagecraft_production" | psql villagecraft_production'
# end

