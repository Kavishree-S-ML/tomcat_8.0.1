# Class: tomcat::params
#
# This class manages Apache-tomcat parameters
#
# Parameters:
# - The $tomcat_port is the port number under which the tomcat server have to run

class tomcat::params {
        $tomcat_port                       = '2019'
        $tomcat_group                      = 'tomcat'
	$tomcat_username                   = 'tomcat'
        $tomcat_password                   = 'password'
}

