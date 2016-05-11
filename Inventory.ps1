# Create a new spreadsheet
$excel = New-Object -ComObject excel.application
$excel.visible = $True

# Add a workbook
$workbook = $excel.Workbooks.Add()

# To add more worksheets just does 
# more on this later...
#$workbook.Worksheets.Add()
#$statsWkSheet = $workbook.Worksheets.Item(2)
#$statsWkSheet.Name = 'Stats'

# Delete some sheets
# $wokbook.Worksheets.Item(2).Delete()
# $wokbook.Worksheets.Item(3).Delete()

# Create some sheets
$mainWksheet = $workbook.Worksheets.Item(1)
$mainWksheet.Name = 'Main'

# prep the header
$headers = @()
$headers = "VmName", "Hostname", "State", "tools", "Folder", "OS", "NumCPU", "Memory", "mgmtIP", "ProdIP", "Provisioned (GB)", "Used (GB)", "Free (GB)", "Datastore", "VmHost", "Last Backup"

#$headers = "VmName", "Hostname", "state", "tools", "folder", "OS", "NumCPU", "Memory", "mgmtIP", "ProdIP", "Provisioned (GB)", "Used (GB)", "Free (GB)", "Datastore", "VmHost", "Last Backup"

# Build the header
$cellcount = 1

foreach ($header in $headers) {
    $mainWksheet.Cells.Item(1,$cellcount) = $header
    $cellcount++
}


# Build out the report much of this is taken from another script I wrote
# that just built stupid csv files and called Excel to read it.
# This is much more flexible and elegant.
$row = 2
$column = 1
 
$vms = get-vm
foreach($vm in $vms) {

    $vmguest =  get-vmguest -vm $vm

    # Collect some data not exposed directly by get-vm or data that requires some
    # black magic to expose from within a structure.

    $mainWksheet.Cells.Item($row,$column) = $vmguest.vmname
    $column++
    
    $mainWksheet.Cells.Item($row,$column) = $vmguest.hostname
    $column++
    
    $mainWksheet.Cells.Item($row,$column) = $vmguest | Select -ExpandProperty state
    $column++
    
    $mainWksheet.Cells.Item($row,$column) = $vmguest.toolsversion 
    $column++
    
    
    # Folder
    $folder = $vm.folder | select -ExpandProperty Name
    $mainWksheet.Cells.Item($row,$column) = $folder
    $column++
    
    $mainWksheet.Cells.Item($row,$column) = $vmguest.osfullname
    $column++
    
    # how many cpus / how much ram
    $mainWksheet.Cells.Item($row,$column) = $vm.numcpu
    $column++
    
    $mainWksheet.Cells.Item($row,$column) = $vm.memorymb
    $column++
   
    # I'd like to find an equivelant of Perls precompiled regexes in PS to 
    # make this a litle more usable as not everyone has a managment network
    # something like: 
    # my $x = qr#^(172|192|xxx)\.(22|168|yy)\.#
    # if ( define $mgmtIP =~ $x ) { #DO STUFF# }
    #
    # Tierpoint managment IP
    $mainWksheet.Cells.Item($row,$column) = $vmguest.IPAddress | where-object { $_ -match "172.22." }
    $column++

    # customer production IPs
    $mainWksheet.Cells.Item($row,$column) = $vmguest.IPAddress | where-object { $_ -notmatch "172.22." -and  $_ -match "^\d" -and $_ -notmatch "0.0.0.0" -and $_ -notmatch "169.254.\d+.\d+" }
    $column++
    
    # disk provisioned / used
    $provisioned = $vm.provisionedspacegb
    $mainWksheet.Cells.Item($row,$column) = $provisioned
    $column++
    
    $used = $vm.usedspacegb
    $mainWksheet.Cells.Item($row,$column) = $used
    $column++
    
    # Free disk space
    $free = $provisioned - $used
    $mainWksheet.Cells.Item($row,$column) = $free
    $column++

    # What datastore does this sit on - if the vm is on
    # several datastores, some massaging may be necessary
    $datastore = $vm | get-datastore | Select -ExpandProperty Name
    $mainWksheet.Cells.Item($row,$column) = $datastore
    $column++
   
    # What host
    $vmhost = $vm.vmhost | Select -ExpandProperty Name
    $mainWksheet.Cells.Item($row,$column) = $vmhost 
    $column++
    
    # Last backup muthereffa
    $lastbackup = $vm.customfields["Last Backup"]
    $mainWksheet.Cells.Item($row,$column) = $lastbackup
    # End of data stream
    
    # Increment Rows
    $row++
    
    # reset column
    $column = 1
}

 
 

