# docker-symfony-test

Docker image for Symfony2 app testing, containing git, nginx, php-fpm, apc, [composer](https://getcomposer.org/) & [php-cs-fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer).

## Usage

### With GitlabCI

```yaml
TODO
```

### With CLI

```bash
docker run -d --rm -ti -p 8080:80 -v /home/michel.dhuyteza/www/thom/thom-platine:/var/www -e "SYMFONY_ENV=test" -e "SYMFONY_DEBUG=1" mroca/symfony-test
```

### With docker-compose

```yaml
app:
  image: mroca/symfony-test
  ports:
    - "8080:80"
  volumes:
    - ./:/var/www
    - /var/www/app/cache
    - /var/www/app/logs
  environment:
    DOMAIN_NAME: app.project.docker
    SYMFONY_ENV: dev
    SYMFONY_DEBUG: 1
    SYMFONY_HIDE_DEPRECATED: true
```
