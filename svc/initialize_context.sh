#!/bin/bash
set -e

echo "Initializing tomcat context"

echo ">> Get central DEV configuration"


#JDBC_IFTA_URL=$(configuration-cmd get -namespace ifta ifta.jdbc.ifta.url)
JDBC_IFTA_URL="jdbc:postgresql://ifta-rds.napp.erdmg.com:5432/ifta"
JDBC_IFTA_USERNAME=$(configuration-cmd get -namespace ifta ifta.jdbc.ifta.username)
JDBC_IFTA_PASSWORD=$(configuration-cmd get -namespace ifta ifta.jdbc.ifta.password)

JDBC_JOURNEY_PASSWORD=$(configuration-cmd get -namespace tomcat tomcat.jdbc.journey.password)

JDBC_OFFHIGHWAY_URL=$(configuration-cmd get -namespace off-highway off-highway.jdbc.off-highway.url)
JDBC_OFFHIGHWAY_USERNAME=$(configuration-cmd get -namespace off-highway off-highway.jdbc.off-highway.username)
JDBC_OFFHIGHWAY_PASSWORD=$(configuration-cmd get -namespace off-highway off-highway.jdbc.off-highway.password)

JDBC_LOGBOOKNZ_PASSWORD=$(configuration-cmd get -namespace tomcat tomcat.jdbc.logbooknz.password)
#JDBC_LOGBOOKNZ_URL=$(configuration-cmd get -namespace logbooknz logbooknz.jdbc.logbooknz.url)

# RABBIT_IFTA_PASSWORD=$(configuration-cmd get -namespace ifta ifta.rabbitmq.ifta.password)
# RABBIT_JOURNEY_PASSWORD=$(configuration-cmd get -namespace journey journey.rabbitmq.journey.password)
# RABBIT_OFFHIGHWAY_PASSWORD=$(configuration-cmd get -namespace off-highway off-highway.rabbitmq.off-highway.password)

echo ">> DEV configuration successfully initialized"

echo ">> Tomcat context initalization started"

sed -i -e "s/jdbc.ifta.password/$JDBC_IFTA_PASSWORD/" /usr/local/tomcat/conf/context.xml
sed -i -e "s/jdbc.journey.password/$JDBC_JOURNEY_PASSWORD/" /usr/local/tomcat/conf/context.xml
sed -i -e "s/jdbc.off-highway.password/$JDBC_OFFHIGHWAY_PASSWORD/" /usr/local/tomcat/conf/context.xml
sed -i -e "s/jdbc.logbooknz.password/$JDBC_LOGBOOKNZ_PASSWORD/" /usr/local/tomcat/conf/context.xml
sed -i -e "s/rabbitmq.ifta.password/$RABBIT_IFTA_PASSWORD/" /usr/local/tomcat/conf/context.xml 
sed -i -e "s/rabbitmq.journey.password/$RABBIT_JOURNEY_PASSWORD/" /usr/local/tomcat/conf/context.xml 
sed -i -e "s/rabbitmq.off-highway.password/$RABBIT_OFFHIGHWAY_PASSWORD/" /usr/local/tomcat/conf/context.xml 

sed -i -e "s#jdbc:postgresql://ifta-rds.dev.erdmg.com:5432/ifta#${JDBC_IFTA_URL}#" /usr/local/tomcat/conf/context.xml 

echo ">> Tomcat context initialized successfully"

echo "Starting tomcat"
exec "$@"
