DATA=$(date +%d-%m-%Y)
VMNAME=$1
echo $VMNAME

#Listar todas as vms e jogar em um arquivo
vim-cmd vmsvc/getallvms | sed 's/[[:blank:]]\{3,\}/   /g' | fgrep "[" | fgrep "vmx-" | fgrep ".vmx" | fgrep "/" | awk -F'   ' '{print "\""$1"\";\""$2"\";\""$3"\""}' |  sed 's/\] /\]\";\"/g' | sed 's/\//;/g'> vms_list

#Pegando o datastorage que a VM que está configruada
VMFS_VOLUME=$(grep -E "$VMNAME" vms_list | awk -F ";" '{print $3}' | sed 's/\[//;s/\]//;s/"//g')

#Pegando o ID da VM 
VMID=$(grep -E "$VMNAME" vms_list | awk -F ";" '{print $1}' | sed 's/\[//;s/\]//;s/"//g')

#Pegando o nome da pasta que está a VM dentro do datastorage
VM_FOLDER=$(grep -E "$VMNAME" vms_list | awk -F ";" '{print $4}' | sed 's/\[//;s/\]//;s/"//g')

#Pegando o nome do arquivo .vmx da VM
VMX=$(grep -E "$VMNAME" vms_list | awk -F ";" '{print $5}' | sed 's/\[//;s/\]//;s/"//g')

#Pegando o path do arquivo vmx da VM
VMX_PATH="/vmfs/volumes/${VMFS_VOLUME}/${VM_FOLDER}/${VMX}"

#Pegando a referencia dos HDs da VM e jogando para o arquivo VMX_DIR
grep -E  fileName "$VMX_PATH" | grep vmdk |  sed 's/ "/;/' | cut -d";" -f2 | sed 's/"//' > VMX_DIR



echo "VMFS_VOLUME: "$VMFS_VOLUME
echo "VMID: "$VMID
echo "VM_FOLDER: "$VM_FOLDER
echo "VMX: "$VMX
echo "VM_PATH: "$VMX_PATH
echo $VMX_DIRS
echo /vmfs/volumes/BACKUP/$VM_FOLDER/$VM_FOLDER-$DATA

#Verifica se a pasta existe no meu servidor.
if [ -d "/vmfs/volumes/BACKUP/$VM_FOLDER/$VM_FOLDER-$DATA" ];

then

echo "Existe a pasta"


else

echo "Criando a pasta"

mkdir -p "/vmfs/volumes/BACKUP/$VM_FOLDER/$VM_FOLDER-$DATA"

fi

#Copia o arquivo .vmx para a pasta de backup
cp "$VM_PATH" /vmfs/volumes/BACKUP/ZEUS/$VM_FOLDER/$VM_FOLDER-$DATA

#Remove todos os snpashots da VM
vim-cmd vmsvc/snapshot.removeall $VMID

#Cria um snapshot da VM antes de fazer o backup
vim-cmd vmsvc/snapshot.create $VMID "BACKUP"

#Laço de repetição para percorrer todos os HDs da VM.
while read VM_DIR
do

echo "VM_DIR: "$VM_DIR

#Clonando o HD
vmkfstools -i "/vmfs/volumes/$VMFS_VOLUME/$VM_FOLDER/$VM_DIR"  "/vmfs/volumes/BACKUP$VM_FOLDER/$VM_FOLDER-$DATA/$VM_DIR"

done < VMX_DIR


#Remove o snpashot que foi criando para fazer o backup da maquina.
vim-cmd vmsvc/snapshot.removeall $VMID

