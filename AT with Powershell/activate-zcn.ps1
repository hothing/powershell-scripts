Set-Service upnphost -startuptype automatic
Set-Service fdrespub -startuptype automatic
Set-Service ssdpsrv -startuptype automatic

Start-Service ssdpsrv
Start-Service upnphost
Start-Service fdrespub