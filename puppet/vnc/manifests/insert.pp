define insert_lines($path, $line, $pattern) {
   exec { "/bin/echo $line >> $path; /sbin/service xinetd reload; /usr/sbin/gdm-safe-restart":
      unless => "/bin/egrep -e '$pattern' '$path'",
   }
}
