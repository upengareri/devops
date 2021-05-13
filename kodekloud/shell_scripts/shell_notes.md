# SHELL BASICS
[More detailed notes of the course](https://github.com/kodekloudhub/shell-scripting-for-beginners-course)

## Run script as command
If you plan to run script as command then you need to do following three things -
1. __remove `.sh`__ extension e.g "create-and-launch-rocket" instead of "create-and-launch-rocket.sh"
> this is not mandatory but is best practice
2. add the path of the script to __`$PATH`__ variable e.g `export PATH=$PATH:/home/bob`
> this way the command can be run from location; to check location of command/script use `which <command>`
3. make the script __executable__ e.g `chmod +x /home/bob/create-and-launch-rocket`
-----

