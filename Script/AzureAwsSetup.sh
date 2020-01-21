#!/bin/bash


echo "
__________.__                         .__         _________                __                 __
\______   \  |__   ____   ____   ____ |__|__  ___ \_   ___ \  ____   _____/  |______    _____/  |_
 |     ___/  |  \ /  _ \_/ __ \ /    \|  \  \/  / /    \  \/ /  _ \ /    \   __\__  \ _/ ___\   __|
 |    |   |   Y  (  <_> )  ___/|   |  \  |>    <  \     \___(  <_> )   |  \  |  / __ \\  \___|  |
 |____|   |___|  /\____/ \___  >___|  /__/__/\_ \  \______  /\____/|___|  /__| (____  /\___  >__|
               \/            \/     \/         \/         \/            \/          \/     \/
                                                                                              USA "

echo "AWS/Azure Client Build - REVISION 01 - by Yuri Chamarelli, Grant Vandebrake, Jake Kustan, and Dan Clark
node.js armv7l version 12.11.0 LTS with PM2 and AWS IoT Device SDK and Azure IOT Device
"
echo "Disclamer - Warning: All examples listed are meant to showcase potential use cases.
Always adhere to best practices and mandatory safety regulations. The end-user is soly
responsible for a safe application/implementation of the examples listed - AWS/Azure Client Build."

sleep 5s


#(Execute this logic before start script execution)
read -r -p "Do you accept the term above and wish to continue the installation (y/n)" response
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then

#testing for connection with the internet before execution
echo "Checking PLC internet conection please wait....."
echo -e "GET http://google.com HTTP/1.0|n|n" | nc google.com 80 > /dev/null 2>&1
if [ $? -eq 0 ]; then
echo "Connection established"

#(User chooses the type of client they want to install)
PS3='Please enter your choice: '
options=("AWS Client" "Azure Client")
select opt in "${options[@]}"
do
    case $opt in
        "AWS Client")
         echo "You chose AWS client"
         cd /
         wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/buildroot-armeabihf-bootstrap.sh | sh &> /dev/null
         cd /opt
         export PATH=$PATH:/opt/bin:/opt/sbin
         echo "Installing gcc please wait....."
         ipkg install gcc &> /dev/null
         echo "Installing python2.7 please wait....."
         ipkg install python27 &> /dev/null
         echo "Installing make please wait....."
         ipkg install make &> /dev/null
         echo "Installing xz-utils please wait....."
         ipkg install xz-utils &> /dev/null

         #Checking to see if packages installed.
         echo "Checking to ensure packages were installed please wait....."
         type gcc >/dev/null 2>&1 || { echo >&2 "I require gcc but it's not installed.  Aborting."; break; }
         type python2 >/dev/null 2>&1 || { echo >&2 "I require python27 but it's not installed.  Aborting."; break; }
         type make >/dev/null 2>&1 || { echo >&2 "I require make but it's not installed.  Aborting."; break; }
         type xz >/dev/null 2>&1 || { echo >&2 "I require xz-utils but it's not installed.  Aborting."; break; }
         echo "Packages installed correctly."

		 #setting up NTP server
     echo "Setting up NTP server please wait....."
		 cd /etc/
		 rm -r ntp.conf
		 touch ntp.conf
		 chmod -c 755 /etc/ntp.conf

		 cat << EOF > /etc/ntp.conf

		 # This is the most basic ntp configuration file
		 # The driftfile must remain in a place specific to this
		 # machine - it records the machine specific clock error
		 driftfile /var/lib/ntp/drift
		 # This should be a server that is close (in IP terms)
		 # to the machine.  Add other servers as required.
		 # Unless you un-comment the line below ntpd will sync
		 # only against the local system clock.
		 #
		 server time.google.com
		 #
		 # Using local hardware clock as fallback
		 # Disable this when using ntpd -q -g -x as ntpdate or it will sync to itself
		 #server 127.127.1.0
		 #fudge 127.127.1.0 stratum 14
		 # Defining a default security setting
		 restrict default

EOF



         #Getting nodejs
         echo "Setting up Nodejs please wait....."
		     cd /opt
         wget https://nodejs.org/dist/v12.14.1/node-v12.14.1-linux-armv7l.tar.xz  &> /dev/null
         xz -d node-v12.14.1-linux-armv7l.tar.xz &> /dev/null
         tar -xf node-v12.14.1-linux-armv7l.tar &> /dev/null
         rm -r node-v12.14.1-linux-armv7l.tar &> /dev/null
         mv node-v12.14.1-linux-armv7l nodejs &> /dev/null

         #node config
         cd /opt/nodejs/bin

         chmod -c 7 npm &> /dev/null
         chmod -c 7 node &> /dev/null
         chmod -c 7 npx &> /dev/null
         mv npm npm-org &> /dev/null

         cd /opt/nodejs/lib/node_modules/npm/bin
         chmod -c 7 npm-cli.js &> /dev/null
         chmod -c 7 npm.cmd &> /dev/null
         chmod -c 7 npx &> /dev/null
         chmod -c 7 npx.cmd &> /dev/null
         chmod -c 7 npx-cli.js &> /dev/null
         chmod -c 7 npm &> /dev/null

         cd /opt/nodejs/bin
         ln -s /opt/nodejs/lib/node_modules/npm/bin/npm-cli.js npm &> /dev/null

         cd /
         ln -s /opt/nodejs/bin/node /usr/bin/node &> /dev/null
         ln -s /opt/nodejs/bin/npm /usr/bin/npm &> /dev/null

         cd /usr/bin
         chmod -c 7 node &> /dev/null
         chmod -c 7 npm &> /dev/null

         #(disabling SSL )
         cd /
         npm config set strict-ssl false &> /dev/null

         #Checking if node installed
         echo "Making sure Nodejs installed please wait....."
         type node >/dev/null 2>&1 || { echo >&2 "I require node but it's not installed.  Aborting."; break; }
         echo "Nodejs was installed correctly."


         #Getting .js files for project
         echo "Retrieving .js files please wait....."
         git clone https://github.com/dclark3774/AWS_AZURE_CLIENT.git &> /dev/null
         mkdir /opt/plcnext/projects/awsclient &> /dev/null
         mv /opt/plcnext/AWSCerts /opt/plcnext/projects/awsclient &> /dev/null
         cd AWS_AZURE_CLIENT &> /dev/null
         mv index.js /opt/plcnext/projects/awsclient &> /dev/null
         cd ..
         rm -r AWS_AZURE_CLIENT &> /dev/null
         echo "Installing dependecies please wait....."
         cd /opt/plcnext/projects/awsclient &> /dev/null
         echo "Installing aws-iot-device-sdk please wait....."
         npm install aws-iot-device-sdk &> /dev/null
         echo "Installing express please wait....."
         npm install express &> /dev/null
         echo "Installing net please wait....."
         npm install net &> /dev/null

         #Checking if dependecies installed.
    		 cd /opt/plcnext/projects/awsclient/node_modules
         echo "Checking to make sure dependecies installed please wait....."
    		 if [ ! -d aws-iot-device-sdk  ]; then
    		 echo >&2 "I require aws-iot-device-sdk but it's not installed.  Aborting."; break;
    		 fi
    		 if [ ! -d net ]; then
    		 echo >&2 "I require net but it's not installed.  Aborting."; break;
    		 fi
    		 if [ ! -d express  ]; then
    		 echo >&2 "I require express but it's not installed.  Aborting."; break;
         fi
         echo "Dependecies installed correctly."

         #PM2 installation and configuration.
         echo "downloading and installing npm pm2 auto boot please wait......."
         cd /opt
         npm -g install pm2 &> /dev/null
         ln -s /opt/nodejs/lib/node_modules/pm2/bin/pm2 /usr/bin/pm2 &> /dev/null
         ln -s /opt/nodejs/lib/node_modules/pm2/bin/pm2 /usr/sbin/pm2 &> /dev/null

         #Checking if PM2 installed correctly.
         type pm2 >/dev/null 2>&1 || { echo >&2 "I require pm2 but it's not installed.  Aborting."; break; }
         pm2 start node /opt/plcnext/projects/awsclient/index.js &> /dev/null
         pm2 save &> /dev/null
         pm2 startup &> /dev/null
         echo "npm pm2 auto boot installed"

         echo "Your IOT client is ready"

         echo "Yor IOT Client will be using Port 3999 and 4000."

         break;;

        "Azure Client")
        echo "You chose Azure client"
        cd /
        wget -O - http://ipkg.nslu2-linux.org/optware-ng/bootstrap/buildroot-armeabihf-bootstrap.sh | sh &> /dev/null
        cd /opt
        export PATH=$PATH:/opt/bin:/opt/sbin
        echo "Installing gcc please wait....."
        ipkg install gcc &> /dev/null
        echo "Installing python2.7 please wait....."
        ipkg install python27 &> /dev/null
        echo "Installing make please wait....."
        ipkg install make &> /dev/null
        echo "Installing xz-utils please wait....."
        ipkg install xz-utils &> /dev/null

        #Checking to see if packages installed.
        echo "Checking to ensure packages were installed please wait....."
        type gcc >/dev/null 2>&1 || { echo >&2 "I require gcc but it's not installed.  Aborting."; break; }
        type python2 >/dev/null 2>&1 || { echo >&2 "I require python27 but it's not installed.  Aborting."; break; }
        type make >/dev/null 2>&1 || { echo >&2 "I require make but it's not installed.  Aborting."; break; }
        type xz >/dev/null 2>&1 || { echo >&2 "I require xz-utils but it's not installed.  Aborting."; break; }
        echo "Packages installed correctly."

    #setting up NTP server
    echo "Setting up NTP server please wait....."
    cd /etc/
    rm -r ntp.conf
    touch ntp.conf
    chmod -c 755 /etc/ntp.conf

    cat << EOF > /etc/ntp.conf

    # This is the most basic ntp configuration file
    # The driftfile must remain in a place specific to this
    # machine - it records the machine specific clock error
    driftfile /var/lib/ntp/drift
    # This should be a server that is close (in IP terms)
    # to the machine.  Add other servers as required.
    # Unless you un-comment the line below ntpd will sync
    # only against the local system clock.
    #
    server time.google.com
    #
    # Using local hardware clock as fallback
    # Disable this when using ntpd -q -g -x as ntpdate or it will sync to itself
    #server 127.127.1.0
    #fudge 127.127.1.0 stratum 14
    # Defining a default security setting
    restrict default

EOF

		#setting up Reverse Proxy
    echo "Setting up reverse proxy please wait....."
		 cd /etc/nginx
		 rm -r nginx.conf
		 touch nginx.conf
		 chmod -c 755 /etc/nginx/nginx.conf

		 cat << EOF > /etc/nginx/nginx.conf
		 		user www;
				worker_processes  5;

				error_log  /var/log/nginx/error.log error;
				#error_log  logs/error.log  notice;
				#error_log  logs/error.log  info;

				pid        /run/nginx/nginx.pid;


				events {
					worker_connections  1024;
				}

				http {
					include       mime.types;
					default_type  application/octet-stream;

					log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
									  '$status $body_bytes_sent "$http_referer" '
									  '"$http_user_agent" "$http_x_forwarded_for"';

					map $status $loggable {
						~^[23] 0;
						default 1;
					}

					access_log  /var/log/nginx/access.log  main if=$loggable;

					sendfile        on;
					#tcp_nopush     on;

					#keepalive_timeout  0;
					keepalive_timeout  65;

					#gzip  on;

					upstream fastcgi_backend {
						server	127.0.0.1:9999;
						#server	192.168.48.1:9000;
						#server unix:/var/run/php5-fpm.socket;
						keepalive 32;
					}

					server {
						listen       80;
						return 301 https://$host$request_uri;
					}

					server {
						proxy_pass http://localhost.3010; proxy_http_version 1.1;
						proxy_set_header Upgrade $http_upgrade;
						proxy_set_header Connection 'upgrade';
						proxy_set_header Host $host;
						proxy_cache-bypass $http_upgrade;
					}
					server {

					client_max_body_size 400M;
						#TLS configuration
						listen 443 ssl;
						ssl_certificate         /opt/plcnext/Security/Certificates/https/https_cert.pem;
						ssl_certificate_key     /opt/plcnext/Security/Certificates/https/https_key.pem;
						ssl_ciphers  HIGH:!aNULL:!MD5;
						ssl_prefer_server_ciphers   on;

						#charset koi8-r;

						#access_log  logs/host.access.log  main;


						location ~* ^/_pxc_api/* {
							# pass the _pxc_api json commands to the FastCGI server listening on 127.0.0.1:9999
							fastcgi_pass   fastcgi_backend; 	# upstream set above
							fastcgi_buffers 8 16k;
							fastcgi_buffer_size 32k;
							fastcgi_connect_timeout 300;
							fastcgi_send_timeout 300;
							fastcgi_read_timeout 300;
							fastcgi_intercept_errors off;
							fastcgi_keep_conn on;
							fastcgi_next_upstream error off;
							fastcgi_pass_header status;
							fastcgi_pass_header Authorization;
							expires     off;
							add_header Cache-Control no-cache;
							include        fastcgi_params;
							access_log  /var/log/nginx/host.access.log  combined if=$loggable;
							error_log  	/var/log/nginx/host.error.log  error;
							#add_header X-debug-message "location _pxc_api" always;
						}

						location / {
							root   /opt/plcnext/projects/current/Services/Ehmi;
							add_header X-debug-message "location /" always;

							# ehmi content
							location ~ ^/ehmi/ {
								if (!-d $document_root/) {
									add_header X-debug-message "No HMI project. Redirect." always;
									return 302 /redirect;
								}
								if (!-f /var/tmp/ehmi/hmi.loaded) {
									add_header X-debug-message "HMI project not loaded yet. Wait." always;
									return 503;
								}
								if (-f /var/tmp/ehmi/hmi.busy){
									add_header X-debug-message "HMI project is being changed. Wait." always;
									return 503;
								}
								try_files $uri =404;
								add_header X-Frame-Options SAMEORIGIN;
							}

							if (!-f /var/tmp/ehmi/hmi.loaded) {
								add_header X-debug-message "HMI project not loaded. Redirect." always;
								return 302 /redirect;
							}

							location /favicon. {
								try_files $uri =404;	# ensure no redirect when reading this in parallel with index.html
							}

							try_files $uri $uri/index.html /redirect;
							add_header X-Frame-Options SAMEORIGIN;
						}

						location /wbm {
							alias /var/www/plcnext/wbm;
							index Login.html;
							ssi on;
							expires     off;
							add_header Cache-Control no-cache;

							location ~*.cgi {
								fastcgi_pass 127.0.0.1:9001;
								fastcgi_pass_header Cookie;
								include fastcgi.conf;
							}

							add_header X-Frame-Options SAMEORIGIN;
						}

						location /welcome {
							alias /var/www/plcnext/welcome;
							index index.html;

							add_header X-Frame-Options SAMEORIGIN;
						}

						location /redirect {
							alias /var/www/plcnext/redirect;
							index index.html;
							ssi on;

							add_header X-Frame-Options SAMEORIGIN;
						}
					}
				}

EOF


        #Getting nodejs
        echo "Setting up Nodejs please wait....."
        cd /opt
        wget https://nodejs.org/dist/v12.14.1/node-v12.14.1-linux-armv7l.tar.xz  &> /dev/null
        xz -d node-v12.14.1-linux-armv7l.tar.xz &> /dev/null
        tar -xf node-v12.14.1-linux-armv7l.tar &> /dev/null
        rm -r node-v12.14.1-linux-armv7l.tar &> /dev/null
        mv node-v12.14.1-linux-armv7l nodejs &> /dev/null

        #node config
        cd /opt/nodejs/bin

        chmod -c 7 npm &> /dev/null
        chmod -c 7 node &> /dev/null
        chmod -c 7 npx &> /dev/null
        mv npm npm-org &> /dev/null

        cd /opt/nodejs/lib/node_modules/npm/bin
        chmod -c 7 npm-cli.js &> /dev/null
        chmod -c 7 npm.cmd &> /dev/null
        chmod -c 7 npx &> /dev/null
        chmod -c 7 npx.cmd &> /dev/null
        chmod -c 7 npx-cli.js &> /dev/null
        chmod -c 7 npm &> /dev/null

        cd /opt/nodejs/bin
        ln -s /opt/nodejs/lib/node_modules/npm/bin/npm-cli.js npm &> /dev/null

        cd /
        ln -s /opt/nodejs/bin/node /usr/bin/node &> /dev/null
        ln -s /opt/nodejs/bin/npm /usr/bin/npm &> /dev/null

        cd /usr/bin
        chmod -c 7 node &> /dev/null
        chmod -c 7 npm &> /dev/null

        #(disabling SSL )
        cd /
        npm config set strict-ssl false &> /dev/null

        #Checking if node installed
        echo "Making sure Nodejs installed please wait....."
        type node >/dev/null 2>&1 || { echo >&2 "I require node but it's not installed.  Aborting."; break; }
        echo "Nodejs was installed correctly."


        #Getting .js files for project
        echo "Retrieving .js files please wait....."
        git clone https://github.com/dclark3774/AWS_AZURE_CLIENT.git
        mkdir /opt/plcnext/projects/azureclient
        cd AWS_AZURE_CLIENT
        mv azureClient.js /opt/plcnext/projects/azureclient
        cd ..
        rm -r AWS_AZURE_CLIENT
        echo "Installing dependecies please wait....."
        cd /opt/plcnext/projects/azureclient
        echo "Installing azure-iot-device please wait....."
        npm install azure-iot-device
        echo "Installing azure-iot-device-mqtt please wait....."
        npm install azure-iot-device-mqtt
        echo "Installing express please wait....."
        npm install express
        echo "Installing net please wait....."
        npm install net

        #Checking if dependecies installed.
        cd /opt/plcnext/projects/azureclient/node_modules
        if [ ! -d azure-iot-device  ]; then
   	  	 echo >&2 "I require azure-iot-device but it's not installed.  Aborting."; break;
   		  fi
        if [ ! -d azure-iot-device-mqtt  ]; then
         echo >&2 "I require azure-iot-device-mqtt but it's not installed.  Aborting."; break;
        fi
   		  if [ ! -d net ]; then
   		   echo >&2 "I require net but it's not installed.  Aborting."; break;
   		  fi
   		  if [ ! -d express  ]; then
   		   echo >&2 "I require express but it's not installed.  Aborting."; break;
        fi

        #PM2 installation and configuration.
        echo "downloading and installing npm pm2 auto boot please wait......."
        cd /opt
        npm -g install pm2
        ln -s /opt/nodejs/lib/node_modules/pm2/bin/pm2 /usr/bin/pm2
        ln -s /opt/nodejs/lib/node_modules/pm2/bin/pm2 /usr/sbin/pm2

        #Checking if PM2 installed correctly.
        type pm2 >/dev/null 2>&1 || { echo >&2 "I require pm2 but it's not installed.  Aborting."; break; }
        pm2 start node /opt/plcnext/projects/azureclient/azureClient.js
        pm2 save
        pm2 startup
        echo "npm pm2 auto boot installed"

        echo "Your IOT client is ready"

        echo "Yor IOT Client will be using Port 3999 and 4000."

        break;;
        *) echo "invalid option $REPLY";;
    esac
done

#clean files from PLCnext directory
cd /opt/plcnext
rm -r AzureAwsSetup.sh

echo "for support please post an issue at https://github.com/dclark3774/PLCnext_AWS_AZURE"

echo "thank you for choosing Phoenix Contact"
echo "your AWS/Azure Client installation is complete"

#else for the network checking statment
else
echo "PLC offline, please check you network settings"
fi

fi

echo "Script is done"
