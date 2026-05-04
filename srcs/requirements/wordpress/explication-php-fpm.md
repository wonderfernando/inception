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



Requisito	Status	Observação
Volumes e Persistência	❌ Falha	A avaliação exige que docker volume inspect mostre o caminho /home/login/data/. No seu docker-compose.yml, os volumes são definidos como driver: local sem o mapeamento device para a pasta host. O Makefile cria a pasta, mas o Docker não a utiliza.
Credenciais no .env	⚠️ Risco	O checklist diz: "Todas as credenciais... devem ser definidas em um arquivo .env". Seu projeto usa Docker Secrets em arquivos externos (../secrets/*.txt). Se esses arquivos estiverem no repositório Git, a nota será 0. Além disso, o avaliador pode exigir que as senhas estejam diretamente no .env.
Nomes das Imagens	⚠️ Aviso	A regra diz: "As imagens Docker devem ter o mesmo nome que o serviço". O docker-compose.yml não especifica a tag image:, fazendo com que o Docker as nomeie automaticamente (ex: srcs-nginx), o que pode ser contestado.
Execução do PHP-FPM	⚠️ Aviso	No Dockerfile do WordPress, o comando final é exec php-fpm. No Debian Bullseye, o executável geralmente tem a versão no nome (ex: php-fpm7.4). Se o contêiner não iniciar, a avaliação termina.
🔍 Detalhes Técnicos Encontrados
Volumes: Para passar na inspeção do avaliador, o docker-compose.yml precisaria de uma configuração de bind mount nos volumes nomeados, apontando explicitamente para /home/ferda-si/data/....
Segurança: Notei que no seu .gitignore, as linhas #srcs/*.env e #secrets/*.txt estão comentadas. Se você fez o commit desses arquivos para o Git, isso é considerado falha de segurança (Fraude/Nota 0) segundo as regras do projeto.
MariaDB: O script docker-entrypoint.sh usa cat para ler segredos, o que está correto para Docker Secrets, mas conflita com a regra de "tudo no .env" se o avaliador for estrito.
Conclusão: O projeto está bem estruturado tecnicamente, mas não passará na verificação de volumes e corre sério risco devido à forma como as credenciais são geradas e à possível presença de arquivos sensíveis no Git.