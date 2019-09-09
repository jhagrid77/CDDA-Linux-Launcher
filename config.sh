#!/bin/bash

#sed -i "s|^rollback=(.*)|rollback=($(echo ${rollback[@]}))|g" ./config.sh
rollback=(saves saves_backup graveyard)
