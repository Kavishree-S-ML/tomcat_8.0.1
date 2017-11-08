#! /bin/sh
#################################################
# CATALINA_OPTS
# This are basically JAVA_OPTS but only used by tomcat
# and only run on Tomcat start see
# http://stackoverflow.com/questions/11222365/catalina-opts-vs-java-opts-what-is-the-difference
# for more details
#
################################################

# discourage address map swapping by setting Xms and Xmx to the same value
# http://confluence.atlassian.com/display/DOC/Garbage+Collector+Performance+Issues

# Increase maximum perm size for web base applications to 4x the default amount
# http://wiki.apache.org/tomcat/FAQ/Memoryhttp://wiki.apache.org/tomcat/FAQ/Memory

# Disable remote (distributed) garbage collection by Java clients
# and remove ability for applications to call explicit GC collection

export CATALINA_OPTS="$CATALINA_OPTS -Djava.awt.headless=true -Dfile.encoding=UTF-8 -server -Xms{{ xms }} -Xmx{{ xmx }} -XX:OnOutOfMemoryError=/usr/share/scripts/on_server_crash.sh -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/tomcat7 -XX:MaxPermSize={{ max_perm_size }} -XX:MaxNewSize={{ max_new_size }} -XX:NewSize={{ new_size }} -XX:PermSize={{ perm_size }} -XX:+DisableExplicitGC"

