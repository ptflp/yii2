#!/bin/bash
set -e
# Apache gets grumpy about PID files pre-existing
rm -f /run/apache2.pid
rm -f /run/apache2/apache2.pid
rm -f /var/run/apache2/apache2.pid
if ["$FRONTEND" != "frontend.test"]; then 
	sed -i "s/frontend.test/${FRONTEND}/" /etc/apache2/sites-available/000-default.conf
fi
if ["$BACKEND" != "backend.test"]; then 
	sed -i "s/backend.test/${BACKEND}/" /etc/apache2/sites-available/000-default.conf
fi
ulimit -s unlimited
exec apache2 -DFOREGROUND
