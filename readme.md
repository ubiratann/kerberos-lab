# Scripts de configuração do Kerberos


## Ambiente do laboratorio:

Foram criadas 2 instâncias remotas utilizando o Amazon EC2, onde uma foi escolhida como o servidor e outra como o cliente, para isso foi criado um grupo de segurança que tem apenas a porta 22 (SSH) aberta para conexões externas.

## Servidor
Para configurar o cliente utilize o script `server.sh`, (lembre-se de que este script foi desenvolvido com um firewall permissivo)

## Cliente

Para configurar o cliente utilize o script `client.sh`, (lembre-se de que este script foi desenvolvido com um firewall permissivo)