#!/bin/bash


#-------------JACK CONNECTIONS--------------#


./disconnect_jack-volume_alsa_out.sh

./disconnect_pd_jack-volume.sh


#-------------KILL CLIENTS__________________#

sleep 0.5

./stop_SCide.sh

sleep 2

./stop_pd.sh

sleep 2

./stop_vbap_jack_volume.sh

sleep 2

./stop_jack_volume.sh

sleep 2

./stop_alsa_out.sh

sleep 2

./stop_cadence_catia.sh



sleep 0.5

echo "Acting Voices - Madrigale a Sei Vasi"
echo "See You Later! :)"
