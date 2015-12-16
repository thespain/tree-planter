#/bin/bash

scl enable httpd24 "/usr/bin/ruby /usr/local/bin/passenger-install-apache2-module --apxs2-path='/opt/rh/httpd24/root/usr/bin/apxs' --languages=ruby --auto"
scl enable httpd24 "/usr/bin/ruby /usr/local/bin/passenger-config validate-install --validate-apache2 --auto"
echo "Passenger install script complete."
