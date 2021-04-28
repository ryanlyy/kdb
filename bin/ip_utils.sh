#!/usr/bin/bash

iphex2str()
{
    hexaddr=$1
    ipaddr=$(printf "%d." $(echo $hexaddr | sed 's/../0x& /g' | tr ' ' '\n' | tac) | sed 's/\.$/\n/')
    echo $ipaddr
}

porthex2int()
{
    hexport=$1
    echo $((16#$hexport))
}

ipstr=$(iphex2str "123E4F67")
echo $ipstr

port=$(porthex2int "238B")
echo $port
