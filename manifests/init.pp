#!/bin/bash
# INSTALL TOMCAT WEBSERVER
# CALL THE PARAMETER FILE
include ::tomcat::params
class tomcat (
  $tomcat_port                                               = $::tomcat::params::tomcat_port,
  $tomcat_group                                              = $::tomcat::params::tomcat_group,
  $tomcat_username                                            = $::tomcat::params::tomcat_username,
  $tomcat_password                                            = $::tomcat::params::tomcat_password,
) inherits ::tomcat::params {
  # INSTALLING Java 1.8
  package { 'java-1.7.0-openjdk-devel':
    ensure => installed,
    name   => 'java-1.7.0-openjdk-devel',
  }
  
  #ADD A GROUP
  group { 'tomcat':
    ensure => present,
    name   => $tomcat_group,
  }

  #ADD AN USER
  user { 'tomcat':
    ensure   => present,
    gid      => $tomcat_group,
    password => $tomcat_password,
    name     => $tomcat_username,
    home     => "/opt/tomcat",
  }
  
  #DOWNLOAD TOMCAT TAR FILE FROM THE SOURCE URL UNDER ROOT FOLDER
  exec { 'download tomcat':                       # exec resource named 'systemd daemon-reload'
    command => 'wget "http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz" --user-agent="Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36" -P ~',  # command this resource will run
    path => ['/usr/bin'],
    logoutput => true,
    returns => [0,1],
  }

  #EXTRACT TOMCAT TAR FILE IN SPECIFIC FOLDER
  exec { 'untar tomcat':                       # exec resource named 'systemd daemon-reload'
    command => 'mkdir -p /opt/tomcat/ && tar xvf /root/apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1',  # command this resource will run
    path => ['/usr/bin'],
    logoutput => true,
    returns => [0,1],
  }
   
  #CHANGE THE OWNERSHIP OF TOMCAT INSTALLATION
  file { '/opt/tomcat':
    owner => $tomcat_group,
    group => $tomcat_group,
    recurse => true,
    source => '/opt/tomcat',
  }

  exec { 'give_read_access_conf':   
    command => "chmod -R g+r /opt/tomcat/conf",  # command this resource will run
    path => ['/usr/bin'],
    logoutput => true,
    returns => [0,1],
  } 

  exec { 'execute_access_conf':   
    command => "chmod g+x /opt/tomcat/conf",  # command this resource will run
    path => ['/usr/bin'],
    logoutput => true,
    returns => [0,1],
  }
  
  exec { 'tomcat_user_as_owner ':   
    command => "chown -R ${tomcat_username} /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/",  # command this resource will run
    path => ['/usr/bin'],
    logoutput => true,
    returns => [0,1],
  }

  #CONFIGURE TOMCAT SERVER FILE
  file{ '/opt/tomcat/conf/server.xml':
    ensure  =>  'file',
    mode    => "0755",
    content =>  template("tomcat/server.xml.erb"),
  }

  #CONFIGURE TOMCAT USER FILE
  file{ '/opt/tomcat/conf/tomcat-users.xml':
    ensure  =>  'file',
    mode    => "0755",
    content =>  template("tomcat/tomcat-users.xml.erb"),
  }

  #CONFIGURE TOMCAT SERVICE FILE
  file{ '/etc/systemd/system/tomcat.service':
    ensure  =>  'file',
    mode    => "0755",
    content =>  template("tomcat/tomcat.service"),
  }
  
  # CONFIGURING THE FIREWALL
  #The web server requires an open port so people can access the pages hosted on our web server. 
  #The open problem is that different versions of Red Hat Enterprise Linux uses different methods for controlling the firewall. 
  #For Red Hat Enterprise Linux 6 and below, we use iptables. 
  #For Red Hat Enterprise Linux 7, we use firewalld
  #Use the operatingsystemmajrelease fact to determine whether the operating system is Red Hat Enterprise Linux 6 or 7.
  if $operatingsystemrelease =~ /^7.*/ {
    #RUNS FIREWALL-CMD TO ADD A PERMANENT FIREWALL RULE
    exec { 'firewall-cmd':
      command => "firewall-cmd --zone=public --add-port=${tomcat_port}/tcp --permanent",
      path => ['/usr/bin'],
      logoutput => true,
      notify => Service["firewalld"],  #checks our firewall for any changes. If it changed, Puppet restarts the service
    }

    #RESTART THE FIREWALLD SERVICE
    service { 'firewalld':
      ensure => running,
    }
  }elsif $operatingsystemrelease =~ /^6.*/ {
    #RUNS IPTABLES-CMD TO ADD A PERMANENT FIREWALL RULE 
    exec { 'iptables':
      command => "iptables -I INPUT 1 -p tcp -m multiport --ports ${tomcat_port} -m comment --comment 'Custom HTTP Web Host' -j ACCEPT &amp;&amp; iptables-save > /etc/sysconfig/iptables",
      path => ['/sbin'],
      logoutput => true,
      notify => Service["iptables"],  #checks our firewall for any changes. If it changed, Puppet restarts the service
    }

    #RESTART THE FIREWALLD SERVICE
    service { 'iptables':
      ensure => running,
    }
  }  

  #RELOAD THE SYSTEMD
  exec { 'systemd_daemon_reload':                       # exec resource named 'systemd daemon-reload'
    command => 'systemctl daemon-reload',  # command this resource will run
    path => ['/usr/bin'],
    logoutput => true,
    returns => [0,1],
  }

  #RELOAD THE SYSTEMD
  exec { 'systemd_start_tomcat':                       # exec resource named 'systemctl start tomcat'
    command => 'systemctl start tomcat',  # command this resource will run
    path => ['/usr/bin'],
    logoutput => true,
    returns => [0,1],
  }

  #RELOAD THE SYSTEMD
  exec { 'systemd_enable_tomcat':                       # exec resource named 'systemctl enable tomcat'
    command => 'systemctl enable tomcat',  # command this resource will run
    path => ['/usr/bin'],
    logoutput => true,
    returns => [0,1],
  }
}
