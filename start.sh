# This script is used to set up a websocket server and modify the main.js file for a web application.
# It copies static files to the nginx directory and starts the nginx server.
# It also modifies the websocket path and port in the main.js file based on environment variables.

# Define a parameter for the websocket path, default to "ws-pass" if not provided
WS_PATH=${WS_PATH:-"ws-pass"}
WS_PORT=${WS_PORT:-"10095"}

cd /workspace/FunASR/runtime

# start the websocket server
bash run_server_2pass.sh

# copy the static files to the nginx directory
cp /workspace/FunASR/runtime/html5/static/* /var/www/html/

# modify the main.js file to set the websocket port and path
sed -i "s/^now_ipaddress=now_ipaddress.replace(localport,\"10095\");/now_ipaddress=now_ipaddress.replace(localport,\"$WS_PORT\"); \nnow_ipaddress += \"$WS_PATH\";/;" /var/www/html/main.js
echo "start nginx."
nginx -g "daemon off;"

