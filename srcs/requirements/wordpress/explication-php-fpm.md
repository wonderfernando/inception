# [www]
Nome do pool do php-fpm. Um pool é uma instância de processos PHP. www é o nome padrão — podes ter múltiplos pools com nomes diferentes.

# user = www-data
# group = www-data
Utilizador e grupo com que os processos PHP correm. www-data é o utilizador padrão do servidor web em Debian/Ubuntu.

# listen = 9000
Porto onde o php-fpm escuta por conexões FastCGI. Tem de corresponder ao fastcgi_pass do NGINX:

# listen.owner = www-data
# listen.group = www-data
Define quem tem permissão para se ligar ao socket. Como estás a usar TCP (porta 9000) em vez de socket Unix, estas linhas são tecnicamente irrelevantes — mas não causam problema.

# pm = dynamic
Modo de gestão de processos. dynamic significa que o número de processos varia conforme a carga. As outras opções seriam static (número fixo) ou ondemand (cria processos só quando necessário).

# pm.max_children = 5
Máximo de processos PHP a correr em simultâneo. Com 5 consegues tratar 5 pedidos PHP ao mesmo tempo.


# pm.min_spare_servers = 1
Mínimo de processos em espera (idle). Garante que há sempre pelo menos 1 processo pronto a responder.

# pm.max_spare_servers = 3
Máximo de processos em espera. Se houver mais de 3 idle, o php-fpm mata os excedentes para poupar memória.

# pm.max_requests = 500
Após processar 500 pedidos, o processo é reiniciado. Previne fugas de memória em scripts PHP mal escritos.


