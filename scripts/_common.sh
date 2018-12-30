#/bin/bash

install_duniter_debian_package() {
	version="v1.6.25"
	git_repo="https://git.duniter.org/nodes/typescript/duniter/"
	if [ $arch == "x64" ]; then
		middle_url="-/jobs/7062/artifacts/raw/work/bin/"
	else
		middle_url="uploads/722c2b2901e0c2a13ca3595eae4e696f/"
	fi
	deb="duniter-server-$version-linux-$arch.deb"
	url="${git_repo}${middle_url}${deb}"

	# Retrieve debian package and install it
	wget -nc --quiet $url -P /tmp
	deb_path="/tmp/$deb"
	dpkg -i $deb_path > /dev/null
	rm -f $deb_path
}

config_duniter() {
	duniter config --ipv4 127.0.0.1 --port $port --remoteh $domain --remotep 80 --noupnp
	duniter config --addep "BMAS $domain 443"
	duniter config --ws2p-host 127.0.0.1 --ws2p-port 20901 --ws2p-remote-host $domain --ws2p-remote-port 443 --ws2p-noupnp
}

config_ssowat() {
	# Add admin to the allowed users
	yunohost app addaccess $app -u $admin

	# Protect senstive sub-routes
	ynh_app_setting_set "$app" protected_uris "/webui","/webmin"

	# Duniter is public app, with only some parts restricted in nginx.conf
	ynh_app_setting_set "$app" unprotected_uris "/","/modules"

	# Set URL redirection from root to webadmin
	ynh_app_setting_set "$app" redirected_urls "{'$domain/':'$domain/webui'}"
}

remove_duniter() {
	# Stop duniter daemon if running
	duniter status
	if [ `echo "$?"` == 0 ]; then
	    duniter stop
	fi

	# Remove Duniter package
	dpkg -r duniter
}
