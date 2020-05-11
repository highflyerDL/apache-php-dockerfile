# apache-php-dockerfile

Dockerfile that installs latest Apache/PHP from source. Tested on:

- MacOS 10.15.2
- docker-compose version 1.24.1, build 4667896b
- Docker version 19.03.2, build 6a30dfc

### Build

```sh
docker-compose build
```

### Start container

```sh
docker-compose up
```

### Check PHP info

```sh
docker exec apache-php-dockerfile_web_1 sh -c "php -i"
```

Alternatively, after container is started successfully, navigating to `localhost` also displays `phpinfo()`

### Logs

All logs from container are stored in `logs` folder
