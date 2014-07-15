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
		creates => "/opt/spark/apache-spark-2.0.9-bin.tar.gz",
		alias => "Download_tar",
	}
	
	# Extract Cassandra
	exec { "tar zxvf apache-spark-2.0.9-bin.tar.gz -C /opt/spark":
    		cwd => "/opt/spark/",
        	creates => "/opt/spark/apache-spark-2.0.9",
		alias => "extract",
		require => Exec['Download_tar']
	}
	
	# Startup script
	file { "/etc/init.d/spark":
		mode => 755,
		alias => "Init Script",
		content => template("spark/spark.erb"),
	}	

	# Copy spark.yaml
	file { "${spark::params::spark_home}/conf/spark.yaml":
             	ensure => 'file',
             	content => template("spark/spark.yaml.erb"),
	   	require => Exec['extract']
	}

	# Copy sparkenv.sh
	file { "${spark::params::spark_home}/conf/spark-env.sh":
                ensure => 'file',
                content => template("spark/spark-env.sh.erb"),
                require => Exec['extract']
 	}
 		
}
