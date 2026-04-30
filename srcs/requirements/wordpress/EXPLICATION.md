# Guia do Projeto Inception

Projeto Docker com uma stack WordPress completa: NGINX (reverse proxy com TLS), PHP-FPM (WordPress), e MariaDB.

---

## Conceitos Fundamentais

### O que é Docker?

Docker é uma plataforma para criar e executar aplicações dentro de **containers** - ambientes isolados que contêm tudo necessário para rodar um software (código, runtime, bibliotecas, configurações).

### O que é um Container?

Um container é um processo isolado do sistema operativo, semelhante a uma máquina virtual leve. Cada container:
- Executa num ambiente isolado (filesystem, rede, processos próprios)
- Partilha o kernel do host (mais leve que VMs tradicionais)
- É portátil entre sistemas com Docker instalado

### O que é uma Imagem Docker?

Umaimagem é um template只读 usado para criar containers. Quando você executa uma imagem, Docker cria um container活实例. imagens são construídas a partir de **Dockerfiles**.

### O que é Docker Compose?

Docker Compose é uma ferramenta para definir e executar aplica Docker Compose é uma ferramenta para定义和运行多容器应用。 Compose usa um ficheiro YAML (`docker-compose.yml`) para配置 todos os serviços da aplicação.

---

## Estrutura do Projeto

```
/home/ferda-si/inception/
├── Makefile              # Comandos de gestão
├── README.md            # Documentação
├── AGENTS.md            # Instruções para agentes
├── .gitignore
├── secrets/              # Credenciais (não commitado)
│   ├── db_password.txt
│   └── dbdb_root_password.txt
└── srcs/
    ├── docker-compose.yml    # Orchestração dos serviços
    ├── .env                 # Variáveis de ambiente
    └── requirements/
        ├── nginx/            # Container NGINX
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress/        # Container WordPress + PHP-FPM
        │   ├── Dockerfile
        │   ├── conf/php-fpm.conf
        │   └── tools/entrypoint.sh
        └── mariadb/          # Container MariaDB
            ├── Dockerfile
            ├── tools/
            │   ├── init.sql
            │   └── docker-entrypoint.sh
```

---

## Arquitetura

```
[Browser:7777] → [nginx:7777] → [wordpress:9000] → [mariadb:3306]
            (TLS)           (FastCGI)        (MySQL)
```

Fluxo:
1. **Browser** conecta a `https://ferda-si.42.fr:7777`
2. **NGINX** recibe pedido, verifica TLS (certificado auto-assinado), forwardeia para WordPress
3. **WordPress (PHP-FPM)** processa PHP, retorna conteúdo
4. **MariaDB** persiste dados do WordPress

---

## Arquivos Principais

### `srcs/docker-compose.yml`

Ficheiro de orquestração que define 3 serviços:

| Serviço | Imagem Base | Porto | Descrição |
|---------|-------------|-------|-----------|
| `nginx` | `debian:bullseye-slim` | 7777 | Reverse proxy com TLS |
| `wordpress` | `debian:bullseye-slim` | 9000 | PHP-FPM + WordPress |
| `mariadb` | `debian:bullseye-slim` | 3306 | Base de dados |

Elementos importantes:
- **networks**: `inception_network` (bridge) - conecta os containers entre si
- **volumes**: `wordpress_data` (partilhado entre nginx e wordpress), `database` (MariaDB)
- **secrets**: credenciais montadas em `/run/secrets/`
- **depends_on**: nginx depende de wordpress, wordpress depende de mariadb (saudável)
- **healthcheck**: MariaDB precisa estar "saudável" antes de WordPress iniciar

### `requirements/nginx/Dockerfile`

```dockerfile
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    nginx \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/nginx/certs

# Gera certificado TLS auto-assinado
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/key.pem \
    -out /etc/nginx/certs/cert.pem \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=ferda-si.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 7777

CMD ["nginx", "-g", "daemon off;"]
```

Passos:
1. Base: Debian Bullseye Slim
2. Instala NGINX e OpenSSL
3. Gera certificado auto-assinado (CN=ferda-si.42.fr)
4. Copia configuração
5. Expõe porto 7777
6. Ejecuta NGINX em foreground

### `requirements/wordpress/Dockerfile`

```dockerfile
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-intl \
    php7.4-zip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/www/html \
    && mkdir -p /run/php

# Download e extração do WordPress
RUN curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 \
    && rm /tmp/wordpress.tar.gz

# Configuração inicial
RUN cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

COPY conf/php-fpm.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

CMD ["/entrypoint.sh"]
```

Passos:
1. Base: Debian com PHP-FPM 7.4 e extensões necessárias
2. Faz download do WordPress (latest.tar.gz)
3. Copia `wp-config-sample.php` para `wp-config.php`
4. Copia config PHP-FPM e entrypoint
5. Executa entrypoint que configura credenciais no wp-config.php

### `requirements/mariadb/Dockerfile`

```dockerfile
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/lib/mysql /run/mysqld

RUN chown -R mysql:mysql /var/lib/mysql /run/mysqld

COPY tools/init.sql /tmp/init.sql
COPY tools/docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["mysqld", "--user=mysql", "--datadir=/var/lib/mysql", "--bind-address=0.0.0.0"]
```

Passos:
1. Base: Debian com MariaDB Server/Client
2. Criar diretórios necessários
3. Copia script de inicialização e init.sql
4. Executa entrypoint que:
   - Inicializa BD se `/var/lib/mysql` vazio
   - Executa init.sql com CREATE USER e CREATE DATABASE

### `srcs/requirements/nginx/conf/nginx.conf`

Configuração do NGINX como reverse proxy:

```nginx
events {
    worker_connections 1024;
}

http {
     include /etc/nginx/mime.types;
     server {
        listen 7777 ssl;  # SSL/TLS obrigatório
        server_name ferda-si.42.fr;

        ssl_certificate     /etc/nginx/certs/cert.pem;
        ssl_certificate_key /etc/nginx/certs/key.pem;
        ssl_protocols       TLSv1.2 TLSv1.3;  # Apenas TLS seguro

        root  /var/www/html;
        index index.php;

        location / {
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_pass wordpress:9000;  # Forward para PHP-FPM
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
}
```

### `srcs/requirements/wordpress/tools/entrypoint.sh`

Script que executa ao iniciar o container WordPress:

1. Lê a password do secret (ou variável de ambiente)
2. Usa `sed` para substituir placeholders no `wp-config.php`:
   - `database_name_here` → `${WORDPRESS_DB_NAME}`
   - `username_here` → `${WORDPRESS_DB_USER}`
   - `password_here` → `${DB_PASSWORD}`
   - `localhost` → `${WORDPRESS_DB_HOST}` (mariadb)
3. Ejecuta `php-fpm7.4` em foreground

### `srcs/requirements/mariadb/tools/docker-entrypoint.sh`

Script que executa ao iniciar o container MariaDB:

1. Verifica se `/var/lib/mysql` está vazio
2. Se vazio, executa `mysql_install_db` (primeira instalação)
3. Substitui placeholder no `init.sql` com a password
4. Executa `mysqld` com `--init-file` para criar BD, user e tabelas

### `srcs/requirements/mariadb/tools/init.sql`

SQL executado na primeira instalação:

```sql
CREATE DATABASE IF NOT EXISTS fernando_wordpress;
CREATE USER IF NOT EXISTS 'ferna

udo_wp'@'%' IDENTIFIED BY '[WORDPRESS_DB_PASSWORD]';
GRANT ALL PRIVILEGES ON fernando_wordpress.* TO 'fernando_wp'@'%';
FLUSH PRIVILEGES;
```

Cria a base de dados e o utilizador para WordPress.

### `srcs/.env`

```env
WORDPRESS_DB_NAME=fernando_wordpress
WORDPRESS_DB_USER=fernando_wp
WORDPRESS_DB_HOST=mariadb
```

---

## Comandos (Makefile)

```bash
make              # build + up (todos os serviços)
make up           # inicia apenas containers
make down         # para containers
make clean        # para + remove containers + volumes + /home/fernando/data
make re          # clean + build + up
make logs        # tail todos os logs
```

---

## Glossário

| Termo | Definição |
|------|----------|
| **Imagem** | Template隻讀 usado para criar containers |
| **Container** | Instância活de uma imagem |
| **Volume** | Diretório persistido fora do container |
| **Network** | Rede virtual que conecta containers |
| **Secret** | Ficheiro com credenciais montado em `/run/secrets/` |
| **Reverse Proxy** | Servidor que recebe pedidos e distribui a outros servidores |
| **FastCGI** | Protocolo para comunicar entre servidor web e PHP-FPM |
| **Healthcheck** | Verificação periódica do estado de um serviço |

---

## Notas Importantes

- **TLS**: Certificado auto-assinado com CN `ferda-si.42.fr`. Browsers mostrarão aviso de segurança.
- **Persistência**: Os volumes `database` e `wordpress_data` persistem dados entre reinícios. `make clean` remove-os.
- **Secrets**: Ficheiros em `secrets/` contêm passwords reais (não versionados).
- **Init SQL**: MariaDB só executa `init.sql` na primeira vez (se `/var/lib/mysql` vazio).
- **PHP-FPM**: Escuta em TCP (`wordpress:9000`), não socket UNIX.