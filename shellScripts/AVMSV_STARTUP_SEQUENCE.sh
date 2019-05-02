#!/bin/bash

./start_cadence_catia.sh

sleep 2

./start_alsa_out.sh

sleep 2

./start_jack_volume.sh

sleep 2

./start_vbap_jack_volume.sh





#-------------JACK CONNECTIONS--------------#

./connect_jack-volume_alsa_out.sh

sleep 0.5

#./connect_pd_jack-volume.sh

echo "Acting Voices - Madrigale a Sei Vasi"
