#!/bin/bash -e

echo ">> $0 starting Glassfish..."

if [ ! -z $DEBUG_GLASSFISH ]; then
    echo ">> Enabling Glassfish debugging"
    DEBUG_GLASSFISH="--debug"
fi

if [ -f /opt/eroad/glassfish/glassfish_configured ]; then
    echo ">> Glassfish has already been configured. Remove this container to reconfigure it"
    asadmin start-domain --verbose $DEBUG_GLASSFISH
    exit 0
fi

# If the USE_LOCAL_INFRASTRUCTURE is unset, then configure for DEV.
if [ -z $USE_LOCAL_INFRASTRUCTURE ]; then

    echo ">> Configuring Glassfish for DEV connectivity"
    asadmin start-domain

    echo ">> Exporting dynamic configuration"
    configuration-cmd export -d -f BASH -n global 1>/tmp/exported

    echo ">> Sourcing dynamic configuration"
    echo "(If this fails weirdly, then someone probably put unsafe chars in a config somewhere.)"

    sed 's/`/\\`/g' /tmp/exported > /tmp/exported2

    source /tmp/exported2
    export $(cut -d= -f1 /tmp/exported2)

    find /opt/eroad/glassfish -name "*_update_asadmin.commands" -exec bash -c 'envsubst < {} > {}.expanded' \;
    find /opt/eroad/glassfish -name "*_update_asadmin.commands.expanded" -exec asadmin --user admin --passwordfile /opt/eroad/glassfish/gf5_asadmin.pwd multimode --file {} \;
    find /opt/eroad/glassfish -name "*_update_asadmin.commands.expanded" -exec rm {} \;
    rm /tmp/exported
    rm /tmp/exported2

    echo ">> Configured Glassfish for DEV connectivity"
    asadmin stop-domain
else
    echo ">> Configured Glassfish for local connectivity"
fi

if [ "${AUTODEPLOY}" == "false" ]; then
    echo ">> Not deploying applications"

else
    echo ">> Deploying applications"

    cp /opt/eroad/glassfish/*.ear /opt/glassfish5/glassfish/domains/domain1/autodeploy/
fi

touch /opt/eroad/glassfish/glassfish_configured

asadmin start-domain --verbose $DEBUG_GLASSFISH

