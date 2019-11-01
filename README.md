# backup_vmware_vms
Backup VMs on the vmware using CLI

Para fazer o backup você tem que montar uma partição nfs de outro servidor, no meu caso eu criei /backup.
E todos meus backups vão para o volume /vmfs/volumes/BACKUP.

Envie o arquivo para o servidor vmware via ssh ou sftp, e acesse o servidor via ssh e execute o arquivo.

./backup.sh "nomeVM"


