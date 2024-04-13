## Preparación de entorno
Modificar en el archivo Vagrantfile la interfaz de red correspondiente\. Posteriormente se levanta el nodo con\.
```warp-runnable-command
vagrant up
```
Para aprovisionarlo se utilizará ansible\, y el aprovisionamiento se dividirá en dos playbooks\. El primero instalará las dependencias y los paquetes necesarios para que el nodo pueda usar docker y el segundo se encargará de preparar los contenedores para que funcionen las tecnologías a desplegar\. Para ello se ejecutará\:
```warp-runnable-command
ansible-playbook -i hosts playbook_install_basics.yml
```
y a continuación\:
```warp-runnable-command
ansible-playbook -i hosts playbook_run_containers.yml
```
## Ejecución del cluster
```warp-runnable-command
sudo make build
```
```warp-runnable-command
sudo make connect
```
## Ejecución de los servicios
Dentro del container se deberá crear el directorio en el sistema de archivos hdfs de la siguiente forma\:
```warp-runnable-command
hdfs dfs -mkdir /files && hdfs dfs -copyFromLocal /examples/files/* /files/
```
Se copian los resultados a la máquina local y se podrán analizar en la carpeta output\.
```warp-runnable-command
hdfs dfs -copyToLocal /user/root/output .
```
