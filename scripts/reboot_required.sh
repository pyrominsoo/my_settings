#!/bin/bash
if [ -f /var/run/reboot-required ]; then
    cat /var/run/reboot-required
fi
