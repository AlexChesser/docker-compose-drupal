@ECHO OFF
SET ScriptDir=%~dp0
SET ScriptDir=%ScriptDir:~0,-1%

docker-machine stop
VBoxManage sharedfolder remove default --name "myrepository"  
VBoxManage sharedfolder add default --automount --name "myrepository" --hostpath %ScriptDir%
docker-machine start  
docker-machine ssh default 'sudo mkdir --parents /myrepository'
docker-machine ssh default 'sudo mount -t vboxsf myrepository /myrepository'