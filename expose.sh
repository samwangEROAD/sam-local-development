# If you are getting a permission denied error, you may need to do run this
# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

currentIP=($(/sbin/ifconfig eno1 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}'))
echo "Your current IP is: $currentIP"
sleep 1
echo "Exposing to ${currentIP}:9999/Portal"
read -p 'Press enter to continue: ' varkey
sleep 1
ssh -L ${currentIP}:9999:localhost:9999 localhost

