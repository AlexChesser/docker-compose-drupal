# docker-compose-drupal
technology exploration for docker workflow

## BEFORE YOU START
> All commands have been written and tested in Windows Powershell. If you would like to use GIT bash or another shell (eg: mac terminal)
> you may have to alter the commands slightly so the paths etc... work as expected


## Install Docker Tools
- install docker tools (or run native) https://www.docker.com/products/docker-toolbox (Make sure you have version 1.11 or later)
    - SAY YES to KITEMATIC
- CREATE the default machine: `docker-machine create --driver virtualbox default`
- CONFIGURE the ENVIRONMENT   
`& "C:\Program Files\Docker Toolbox\docker-machine.exe" env | Invoke-Expression`
    - for other environments read: https://docs.docker.com/machine/reference/env/ 

## Setup VIRTUALBOX shared folders

> **before you start this section:**  
> test the command: `VBoxManage` in powershell  
> if your receive an error add `C:\Program Files\Oracle\VirtualBox` to your windows path  
> *temporarily*: `$Env:Path=$Env:Path+";C:\Program Files\Oracle\VirtualBox;"`  
> *permanently*:  http://stackoverflow.com/questions/9546324

* Run `CreateVMFileShare.cmd` 
* from there we must add a hostname to our hosts file (or point the host in DNS):
`192.168.99.100 dev.myrepository.com`
* for **DEV**:
    - run `build.cmd` (*only required the first time*)
    - run `up.cmd`
    - **You should now be able to browse the site on http://dev.myrepository.com**

## usable batch files

* `build.cmd` - build the myrepository image
* `cn.cmd` - connect to the main web container
* `dbdump.cmd` - create an importable database file for commiting to git
* `export.cmd` - create a DRUPAL tar file for delivering the final code
* `up.cmd` - start the DOCKER "server farm" config 

#Appendix:

## Manually create and run a reverse proxy

We want our DOCKER environment to be able to DYNAMICALLY add websites based on their host name. For this use case we must first startup a reverse proxy container 

    docker run -d -p 80:80 --name reverse-proxy -v /var/run/docker.sock:/tmp/docker.sock -t jwilder/nginx-proxy

## How to read docker RUN commands:
we can also execute some commands manually

    # RUN A CONTAINER 
    #    - NAMED <mysql> 
    #    - IN THE BACKGROUND
    #    - EXPOSE THE DOCKER PORT 3307 as the INTERNAL PORT 3306
    #    - ADD AN ENVIRONMENT VARIABLE - MYSQL_ROOT_PASSWORD
    #    - USE DOCKER IMAGE 'mysql'
    docker run --name mysql -d -p 3307:3306 -e MYSQL_ROOT_PASSWORD=admin123 mysql
    # RUN A CONTAINER 
    #    - NAMED <drupal_2> 
    #    - IN THE BACKGROUND
    #    - ALLOW IT TO ACCESS THE MYSQL container USING THE LOCAL-NAME mysql
    #    - ADD AN ENVIRONMENT VARIABLE for the VIRTUAL_HOST
    #    - USE DOCKER IMAGE 'drupal' with the specific version of '7.44-apache'
    docker run --name drupal_2 -d --link mysql:mysql -e VIRTUAL_HOST=site2.local.com drupal:7.44-apache

    docker run --name myrepository-dev -d --link dockercomposedrupal_mysql_1:mysql -e VIRTUAL_HOST=site1.local.com -e DRUPAL_ENVIRONMENT=development -e BASE_URL=http://site1.local.com myrepository

## Change ADMIN password in drupal

    docker exec myrepository_web_1 drush user-password Admin --password="1234" --uri=myrepository.com

## Get DOCKER MACHINE unstuck (error message might be 'guru meditation')

    vboxmanage controlvm default poweroff

## Create a self signed CERT

    openssl genrsa 2048 > myrepository.key  
    openssl req -new -x509 -nodes -sha1 -days 3650 -subj "/C=CA/ST=ON/O=KatalystAdvantage/CN=*.myrepository.com" -key myrepository.key > myrepository.crt    
    openssl x509 -noout -fingerprint -text < myrepository.crt > myrepository.info  
    cat myrepository.crt myrepository.key > myrepository.pem  
    chmod 400 myrepository.key myrepository.pem  


## Running out of space in docker

If you start to experience VM issues related to the docker machine running out of space, you can run the following command to clean up https://github.com/docker/machine/issues/1779

    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:ro -v /var/lib/docker:/var/lib/docker martin/docker-cleanup-volumes

Also read http://stackoverflow.com/questions/31909979 if it still does not work, you may have "dangling volumes" 

    docker volume rm $(docker volume ls -qf dangling=true)

