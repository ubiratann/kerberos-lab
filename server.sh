#!/bin/bash

set -e	
server_ip='172.31.254.4'
client_ip='172.31.254.5'
kdb_password='kerber0$'

############## Simulando dns ##########################
echo 'setando nome dos hosts'

cat << EOF >> /etc/hosts
$server_ip cdc.sd.com cdc
$client_ip cliente.sd.com cliente
EOF
hostnamectl --static set-hostname cdc.sd.com

################ Instalando Dependências #################
echo 'instalando binarios'
yum install -y krb5-server krb5-workstation pam_krb5

############## Manipulando /etc/krb5.conf #################
echo 'atualizando /etc/krb5.conf'

# Remove comentarios exceto da primera linha
sed -i  '1!s/^#//g' /etc/krb5.conf 

# Substitui configuração com nome dos hosts
sed -i 's/EXAMPLE/SD/g' /etc/krb5.conf
sed -i 's/example/sd/g' /etc/krb5.conf
sed -i 's/kerberos./cdc./g' /etc/krb5.conf

###### Manipulando /var/kerberos/krb5kdc/kadm5.acl #########
echo 'atualizando /var/kerberos/krb5kdc/kadm5.acl'

# Substitui configuração com nome do host
sed -i 's/EXAMPLE/SD/g' /var/kerberos/krb5kdc/kadm5.acl

###### Manipulando /var/kerberos/krb5kdc/kdc.conf ##########
echo 'atualizando /var/kerberos/krb5kdc/kdc.conf'

# Substitui configuração com nome do host
sed -i 's/EXAMPLE/SD/g' /var/kerberos/krb5kdc/kdc.conf

##########  Configurando cdc ##################
echo 'configurando banco de dados'
kdb5_util create -r SD.COM -s -P $kdb_password

systemctl enable kadmin krb5kdc
systemctl start kadmin krb5kdc

##########  Configurando keberos principals ##################

echo 'configurando usuário krbuser'
# Criando credencial para usuario remoto
kadmin.local addprinc -pw qwe123 krbuser 

echo 'configurando usuário kadmin'
# Criando credencial privilegiado pro root
kadmin.local addprinc -pw $kdb_password root/admin
kadmin.local ktadd -k /var/kerberos/krb5kdc/kadm5.keytab kadmin/admin
kadmin.local ktadd -k /var/kerberos/krb5kdc/kadm5.keytab kadmin/changepw

# Criando atribuição randomica de credenciais para os hosts
kadmin.local addprinc -randkey host/cdc.sd.com
kadmin.local ktadd host/cdc.sd.com

echo 'criando usuario krbuser caso ele nao exista'
id -u krbuser &>/dev/null || useradd rkbuser