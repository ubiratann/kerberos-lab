#!/bin/bash

set -e

server_ip='172.31.254.4'
client_ip='172.31.254.5'

sudo su
############## Simulando dns ##########################
echo 'setando nome dos hosts'

cat << EOF >> /etc/hosts
$server_ip cdc.sd.com cdc
$client_ip cliente.sd.com cliente
EOF

hostnamectl --static set-hostname cliente.sd.com

################ Instalando Dependências #################
echo 'instalando binarios'
yum install -y krb5-workstation pam_krb5


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

###### Manipulando /etc/sshd ##########
echo 'atualizando /etc/sshd'

# Habilita autenticacao kerberos
sed -i 's/GSSAPIAuthentication no/GSSAPIAuthentication yes/g' /etc/ssh/sshd_config

# Habilita multisession
sed -i 's/GSSAPICleanupCredentials yes/GSSAPICleanupCredentials no/g' /etc/ssh/sshd_config

# Habilita kerberos a criar os ticket e delegar as credenciais
echo '        GSSAPIDelegateCredentials yes' >> /etc/ssh/ssh_config 

# Restarta sshd e habilita kerberos
echo 'configurando serviço de ssh '
systemctl restart sshd
authconfig --enablekrb5 --update

# Usuario que foi criado no banco de dados do KDC
echo 'criando usuario krbuser caso ele nao exista'
id -u krbuser &>/dev/null || useradd krubser
su -l krbuser