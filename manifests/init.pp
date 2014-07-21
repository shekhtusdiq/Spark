#/etc/puppet/modules/spark/manifests/init.pp
class spark {

require spark::params	

	# Add path in global variable.
	Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
	
	# To test param variables in /tmp/test.txt file.
	file { "/tmp/test.txt":
		ensure => 'file',
		alias => 'Test',
    		content => template("spark/test.txt.erb"),
	}
	
	#  
	package { "wget":
    		ensure => "installed",
		before => File['Test'],
	}

	# Create Installation directory
	file { "${spark::params::install_dir}":
    		ensure => "directory",
        	alias => "Base_dir",
		before => Exec["Download_tar"],
	}

	# Donwload tar file
	exec { "wget $get_url}":
		cwd => "/opt/spark/",
		command => "wget ${spark::params::get_url}",
		creates => "/opt/spark/spark-1.0.1-bin-hadoop1.tgz",
		alias => "Download_tar",
	}
	
	# Extract spark
	exec { "tar zxvf spark-1.0.1-bin-hadoop1.tgz -C /opt/spark":
    		cwd => "/opt/spark/",
        	creates => "${spark::params::spark_home}",
		alias => "extract",
		require => Exec['Download_tar']
	}
	# Copy JRE
        file { "${spark::params::spark_home}/jre-7u55-linux-x64.gz":
                ensure => 'file',
                source => 'puppet:///modules/spark/jre-7u55-linux-x64.gz',
        	#creates => "${spark::params::spark_home}/jre-7u55-linux-x64.gz",
                alias => 'Copy_JRE',
                require => Exec["extract"],
        }
	# Extract JRE
	exec { "tar zxvf jre-7u55-linux-x64.gz":
                cwd => "${spark::params::spark_home}",
                creates => "${spark::params::spark_home}/jre1.7.0_55",
                alias => "Extract_JRE",
                require => File['Copy_JRE']
        }

	# Copy start-salve script
	file { "${spark::params::spark_home}/sbin/start-slave.sh":
		ensure => 'file',
		content => template("spark/sbin/start-slave.sh.erb"),
		require => Exec["extract"],
	}	

	# Copy Slave Information
	file { "${spark::params::spark_home}/conf/slaves":
             	ensure => 'file',
             	content => template("spark/conf/slaves.erb"),
	   	require => Exec['extract']
	}

	# Copy start-all.sh
	file { "${spark::params::spark_home}/sbin/start-all.sh":
                ensure => 'file',
                content => template("spark/sbin/start-all.sh.erb"),
                require => Exec['extract']
 	}
	
	# Copy spark-shell
        file { "${spark::params::spark_home}/bin/spark-shell":
                mode => 755,
		ensure => 'file',
                content => template("spark/bin/spark-shell.erb"),
                require => Exec['extract']
        }
 	
	# Copy spark-shell
        file { "${spark::params::spark_home}/conf/spark-env.sh":
                mode => 755,
                ensure => 'file',
                content => template("spark/conf/spark-env.sh.erb"),
                require => Exec['extract']
        }

	
}
