#!/bin/bash

if [ "srv.villagecraft.org" != "$HOSTNAME" ]; then
        ssh villagecraft@villagecraft.org '
        sudo -i;
        lastcap=$(ls -t /home/villagecraft/www/releases | head -2 | tail -1);
		rm /home/villagecraft/www/current;
		ln -s /home/villagecraft/www/current /home/villagecraft/www/releases/${lastcap};
		cd /home/villagecraft/www/current;
		bundle exec rake db:migrate;
		bundle exec rake daemons:stop;
		'
fi

