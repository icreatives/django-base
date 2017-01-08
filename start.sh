#!/bin/bash

echo ""
echo "Welcome to this Django application platform!"
echo ""

/etc/init.d/postgresql start

/etc/init.d/nginx start

/etc/init/uwsgi.conf start

# uwsgi --ini /etc/uwsgi/vassals/default.ini

echo ""
echo "Ready!"
echo ""

/bin/bash
