#/etc/puppet/modules/spark/manifests/init.pp
class spark {

require spark::params	

	# Add path in global variable.
	Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
	
	# Add Group Spark
	group { "spark":
    		ensure => "present",
    		gid => '1001',
		#before => 'Download_tar',
	}
	
	# Add User Spark
	user { 'spark':
  		ensure           => 'present',
  		gid              => '1001',
  		groups           => 'spark',
  		home             => '${spark::params::install_dir}',
  		password         => '$6$5qu6iW.hdIp$N4TF2DYDkVd0S72OBNeUbEMuv8OOxBuUvsOtfDpc3Pe2/0fqdv.7R5lss7anNoNHYXwd49lK.Y3X5iUUEIN57/',
  		password_max_age => '99999',
  		password_min_age => '0',
  		shell            => '/bin/bash',
  		uid              => '1001',
  		managehome       => true,
  		require          => Group["spark"],
  		before 		 => Exec['Download_tar'],
	}

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
    		owner => 'spark',
		group => 'spark',
    		ensure => "directory",
        	alias => "Base_dir",
	}

	# Donwload tar file
	exec { "wget $get_url}":
		user => 'spark',
		cwd => "/opt/spark/",
		command => "wget ${spark::params::get_url}",
		timeout => 1800,
		tries   => 2,
		creates => "/opt/spark/spark-1.0.1-bin-hadoop1.tgz",
		alias => "Download_tar",
		require => User["spark"],
	}
	
	# Extract spark
	exec { "tar zxvf spark-1.0.1-bin-hadoop1.tgz -C /opt/spark":
    		user => 'spark',
		cwd => "/opt/spark/",
        	creates => "${spark::params::spark_home}",
		alias => "extract",
		require => Exec['Download_tar']
	}
	# Copy JRE
        file { "${spark::params::spark_home}/jre-7u55-linux-x64.gz":
                owner => 'spark',
		group => 'spark',
		ensure => 'file',
                source => 'puppet:///modules/spark/jre-7u55-linux-x64.gz',
                alias => 'Copy_JRE',
                require => Exec["extract"],
        }
	# Extract JRE
	exec { "tar zxvf jre-7u55-linux-x64.gz":
		user => 'spark',
		cwd => "${spark::params::spark_home}",
                creates => "${spark::params::spark_home}/jre1.7.0_55",
                alias => "Extract_JRE",
                require => File['Copy_JRE']
        }

	# Copy start-salve script
	file { "${spark::params::spark_home}/sbin/start-slave.sh":
		ensure => 'file',
		owner => 'spark',
                group => 'spark',
		content => template("spark/sbin/start-slave.sh.erb"),
		require => Exec["extract"],
	}	

	# Copy Slave Information
	file { "${spark::params::spark_home}/conf/slaves":
             	ensure => 'file',
		owner => 'spark',
                group => 'spark',
             	content => template("spark/conf/slaves.erb"),
	   	require => Exec['extract']
	}

	# Copy start-all.sh
	file { "${spark::params::spark_home}/sbin/start-all.sh":
                ensure => 'file',
		owner => 'spark',
                group => 'spark',
                content => template("spark/sbin/start-all.sh.erb"),
                require => Exec['extract']
 	}
	
	# Copy spark-shell
        file { "${spark::params::spark_home}/bin/spark-shell":
                mode => 755,
		owner => 'spark',
                group => 'spark',
		ensure => 'file',
                content => template("spark/bin/spark-shell.erb"),
                require => Exec['extract']
        }
 	
	# Copy spark env
        file { "${spark::params::spark_home}/conf/spark-env.sh":
                mode => 755,
		owner => 'spark',
                group => 'spark',
                ensure => 'file',
                content => template("spark/conf/spark-env.sh.erb"),
                require => Exec['extract']
        }
	file { "${spark::params::install_dir}/.bash_profile":
    		mode => 644,
		owner => 'spark',
		group => 'spark',
		ensure => 'file',
    		content => template("spark/conf/bash_profile.erb"),
		alias => 'Copy_ENV',
		require => Exec['extract']
	}

	
}
