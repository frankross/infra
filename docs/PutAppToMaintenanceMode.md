To put app in maintenance mode , create a file
/etc/nginx/ecom-platform.maintenance. Nginx continously watches this
file and if present starts giving 503 to haproxy.

There is a build in teamcity to put app in maintenance mode.
If you check the maintenance mode in the build it will add this file on
app server and put nginx in maintenance mode
If you dont check the box and run the build, it will remove this file
and take app out of maintenance mode.
There is a separate build for staging and prod. Please make yourself
familiar with the build before triggering it.
