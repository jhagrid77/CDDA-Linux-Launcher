#!/bin/bash

#sed -i "s|^ROLLBACK=(.*)|ROLLBACK=($(echo ${ROLLBACK[@]}))|g" ./config.sh
ROLLBACK=(saves saves_backup graveyard)
