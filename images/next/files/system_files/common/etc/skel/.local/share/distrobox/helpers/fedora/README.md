# Explanation

- Scripts under the 'container_scripts' folder are supposed to run inside the container.
- Script 'run_scripts.sh' runs all scripts under 'container_scripts' folder inside the container.
- Script 'assemble_fedora' fully creates the container, either based on the INI file (/etc/distrobox/distrobox.ini)
  or manually, defined by the script's function (assemble_manually) and then runs all the scripts inside the container.
