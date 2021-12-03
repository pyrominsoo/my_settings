#!/bin/bash    
    
declare -i sinks_count=`pacmd list-sinks | grep -Pc 'index:\s+\d+'`    
    
if [ $sinks_count -eq 0 ] ; then    
    exit    
fi    
    
declare -i active_sink_index=`pacmd list-sinks | grep -Po '\*\s+index:\s+\K\d+'`    
    
active_index_position_found=0    
let next_sink_index=-1    
while read index ;    
do    
    declare -i ind=($(echo $index | tr -dc '[0-9]+'))    
    if [ $next_sink_index -lt 0 ] ; then    
        export next_sink_index=$ind    
    fi    
    if [ $active_index_position_found -eq 1 ] ; then    
        export next_sink_index=$ind    
        break;    
    fi    
    if [ $active_sink_index -eq $ind ] ; then    
        export active_index_position_found=1    
    fi    
done < <(pacmd list-sinks | grep -Po 'index:\s+\K\d+')    
    
#change the default sink    
pacmd "set-default-sink ${next_sink_index}"    
    
#move all inputs to the new sink
for app in $(pacmd list-sink-inputs | grep -Po 'index:\s+\K\d+');
do
    pacmd "move-sink-input $app $next_sink_index"
done
