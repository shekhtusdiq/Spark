class spark::params {
#Install Dir
  $install_dir = $::hostname ? {
  	default => "/opt/spark"
  }

#Spark Home
  $spark_home = $::hostname ? {
	default => "/opt/spark/"
  }

#Spark bin
  $spark_bin = $::hostname ? {
        default => "${spark::params::spark_home}/bin"
  }

#Spark conf
  $spark_conf = $::hostname ? {
        default => "${spark::params::spark_home}/conf"
  }

#Download Url
  $get_url = $::hostname ? {
	default => "http://d3kbcqa49mib13.cloudfront.net/spark-1.0.1-bin-hadoop1.tgz"	
  }

#Cluster name
  $cluster_name = $::hostname ? {
     	default => "Pramti",
  }

#Spark nodes        
  $seeds = $::hostname ? {
    	default => "sparkA, sparkB",
  }
}
