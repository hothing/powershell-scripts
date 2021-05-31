#Enable-WindowsOptionalFeature -FeatureName NetFx3 -Online -All # it will not work - requures package download
Enable-WindowsOptionalFeature -FeatureName MSMQ-Server -Online -All