# docker-symfony-test

Docker image for Symfony2 app testing, containing git, nginx, php-fpm, apc, [composer](https://getcomposer.org/) & [php-cs-fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer).

## Usage

### With GitLab CI

`vim /etc/gitlab-runner/config.toml && gitlab-ctl reconfigure`

```toml
[[runners]]
  name = "Docker in Docker"
  url = "http://ci.domain.name/"
  token = "xxxxxxxxxxxxxxxxxxxxxxxxx"
  limit = 1
  executor = "docker"
  [runners.docker]
    image = "gitlab/dind:latest"
    privileged = true
    volumes = ["/cache"]
    allowed_images = ["mroca/symfony-test"]
    allowed_services = ["mysql:*", "redis:*", "mongo:*"]
```

`.gitlab-ci.yml`

```yaml
image: mroca/symfony-test

before_script:
  - export COMPOSER_CACHE_DIR=/cache/composer
  - composer install --no-interaction

behat:
  script:
    - bin/behat
  tags:
    - docker
```

### With CLI

```bash
docker run -d --rm -ti -p 8080:80 -v /my/local/project:/var/www -e "SYMFONY_ENV=test" -e "SYMFONY_DEBUG=1" mroca/symfony-test
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

## Scripts

### php-cs-fixer-diff

The `php-cs-fixer-diff-cache.sh` script checks the project code style.

Usage :

```bash
php-cs-fixer-diff-cache.sh --cache-dir=/cache
```

Usage with GitLab CI :

```yaml
php_cs_fixer:
  stage: test
  script:
    - /opt/php-cs-fixer-diff-cache.sh --cache-dir=/cache
  tags:
    - docker
```
