class oracle_requisites{

        $osver = $operatingsystemrelease ? {
                /^5/ => '5',
                /^4/ => '4',
                /^6/ => '6',
                default => 'unknown',
        }

	$os = $operatingsystem ? {
		/(?i)^(ol|oel|.*linux.*|RedHat)$/ => 'linux',
		/(?i)^aix$/ => 'aix',
		default	=> undef,
	}

        if $os == 'linux' {
		$ostag = "${osver}_${architecture}"
	}
	else {
		$ostag = 'undef'
	}
		

        if $os == 'linux' {
		package { [ 'firefox', 'vsftpd', 'screen', 'vim-enhanced' ]:
			ensure =>  latest, 
		}

		case $ostag {
			4_i386: {
				# unable to find libXtst and xorg-x11-utils
				package { [ 'make', 'binutils', 'gcc', 'libaio',
					    'glibc-common', 'libstdc++', 'libstdc++-devel',
					    'pdksh', 'setarch', 'sysstat', 'compat-db', 
					    'kernel-utils' ]: 
					   ensure => latest, 
				}
			}
			5_i386: {
				package { [ 'make', 'binutils', 'gcc', 'libaio', 
					    'glibc-common', 'compat-libstdc++-296',
					    'libstdc++', 'libstdc++-devel', 'setarch',
					    'sysstat', 'compat-db', 'libXtst', 'rng-utils',
					    'xorg-x11-utils' ]:
					   ensure => latest,
				}
			}
			5_x86_64: {
				package { [ 'make', 'binutils', 'gcc', 'libaio', 
					    'glibc-common', 'libstdc++', 'setarch',
					    'sysstat', 'libXtst.x86_64', 'glibc-devel.i386',
					    'glibc-devel.x86_64', 'xorg-x11-utils', 'rng-utils' ]:
					   ensure => latest,
				}
			}
		}
 

		service { [ 'vsftpd', 'sysstat', 'sendmail' ]:
			ensure => running,
		        enable => true,
		}

		service { [ 'iptables', 'ip6tables' ]:
			ensure => stopped,
			enable => false, 
		}

	}
}



