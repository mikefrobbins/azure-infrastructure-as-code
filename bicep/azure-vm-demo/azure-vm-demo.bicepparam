using './azure-vm-demo.bicep'

param vmName = 'vm-demo'
param adminUsername = 'azureuser'
param sshPublicKey = readEnvironmentVariable('SSH_PUBLIC_KEY')
