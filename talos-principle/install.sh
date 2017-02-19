#!/bin/bash
HOME=$DEBUG_REAL_HOME steam steam://install/257510
unzip talos-principle.zip
chmod +x pre.sh talos-principle
sh pre.sh
rm pre.sh
