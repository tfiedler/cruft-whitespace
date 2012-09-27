class vnc {

	$os = $operatingsystem ? {
		/(?i)^(ol|oel|.*linux.*|RedHat)$/ => 'linux',
		/(?i)^aix$/ => 'aix',
		default	=> undef,
	}

	$osver = $operatingsystemrelease ? { 
		/^(5|4)(\.\d+)?$/ => 'ok',
		default => 'unknown',
	}

	$config = $operatingsystemrelease ? {
		/^5/ => "/etc/gdm/custom.conf",
		/^4/ => "/etc/X11/gdm/gdm.conf",
		default => 'unknown',
	}

	$tplVer = $operatingsystemrelease ? {
		/^5/ => '5',
		/^4/ => '4',
		default => 'unknown',

	}

	if $os == 'linux' {

		if $osver == 'ok' {

			package { ['xinetd', 'gdm', 'vnc-server']:
				ensure => present,
			}
	
			file { $config:
			       ensure => file,	
			       path => $config,
			       owner => "root",
			       group => "root",
			       mode => 0644,
			       source => "puppet:///modules/vnc/OL${tplVer}Custom.conf",
			       require => Package["vnc-server"],
			}	
			

			file { 'vnc1024':
				path => '/etc/xinetd.d/vnc1024',
				ensure => file,
				content => template("vnc/vnc1024.erb"),
		        }

		        import "insert.pp"
      			insert_lines { '/etc/services':
      				path => "/etc/services",
      				line => "vnc1024        5902/tcp",
      				pattern => "5902\/tcp",
   			}

			service { 'xinetd':
				require => Package['xinetd'],
				ensure => running,
			}

		}
	}
}
