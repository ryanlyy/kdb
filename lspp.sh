#!/usr/bin/bash

NS_NAME=$1
if [[ $NS_NAME != "" ]]; then
        NS_SPACE=" -n $NS_NAME "
fi

OUTPUT_NAME=$2

POD_LIST=$(kubectl get pod $NS_SPACE  -o=custom-columns=NAME:.metadata.name |grep -v NAME)
APP_SET=""
UNIQ_POD_LIST=""

for pod in $POD_LIST; do
        app=$(kubectl describe pod  $NS_SPACE $pod  | grep Labels | cut -d "=" -f2)
        if [[ $APP_SET != *"$app"* ]]; then
                APP_SET="$APP_SET $app"
                UNIQ_POD_LIST="$UNIQ_POD_LIST $pod"
        fi
done
APP_SET=($APP_SET)
CMD_LIST=""
CNAME_LIST=""

echo "POD,Container,Process,CMD,LDD" > $OUTPUT_NAME
for  pod in $UNIQ_POD_LIST; do
        CID_LIST=$(kubectl describe pod  $NS_SPACE $pod $NS_SPACE | grep -1 "Container ID" | grep -v "\-\-" | grep -v Image | grep -v "Container ID" | cut -d ":" -f 1)
        echo "########################################################"
        for cid in $CID_LIST; do
                echo -n "POD: $pod      Container: $cid"
                if [[ $CNAME_LIST == *"$cid"* ]]; then
                        echo " - dup, ignore"
                        continue
                else
                        CNAME_LIST="$CNAME_LIST $cid"
                        echo ""
                fi
                if [[ $cid == "skydns" || $cid == "etcd" ]]; then
                        kubectl exec $NS_SPACE -ti $pod -c $cid -- ps -ef |grep -v cat | grep -v "sleep" | grep -v "COMMAND" | grep -v "ps -ef" > /tmp/$pod.$cid
                        ps_info=$(cat /tmp/$pod.$cid | awk '{ for (n=4; n <= NF; n++){printf " %s", $(n)} print "" }')
                        echo "$pod,$cid,\"$ps_info\",," >> $OUTPUT_NAME
                else
                        kubectl exec $NS_SPACE -ti $pod -c $cid -- ps --no-headers -ewwf |grep -v cat | grep -v "sleep" | grep -v "ewwf" > /tmp/$pod.$cid
                        cat /tmp/$pod.$cid | awk '{ for (n=8; n <= NF; n++){printf " %s", $(n)} print "" }' > /tmp/$pod.$cid.ps
                        while read ps_line
                        do
                                ps_line=${ps_line::-1}
                                cmd=$(echo $ps_line | awk '{ print $1 }')
                                echo "CMD: $cmd"
                                if [[ $cmd == *"bash"* || $cmd == *"python"* || $cmd == *"java"* ]]; then
                                        cmd=$(echo $ps_line | awk '{ print $2 }')
                                        echo "$pod,$cid,\"$ps_line\",$cmd," >> $OUTPUT_NAME
                                        continue
                                fi
                                if [[ $CMD_LIST != *"$cmd"* ]]; then
                                        CMD_LIST="$CMD_LIST $cmd"
                                        #ldd=$(kubectl exec $NS_SPACE $pod -c $cid -- ldd $cmd 2>/dev/null)
                                        kubectl exec $NS_SPACE $pod -c $cid -- ldd $cmd 2>/dev/null > /tmp/$pod.$cid.ps.lib
                                        ldd_info=""
                                        touch /tmp/$pod.$cid.ps.lib.list
                                        while read lib_line
                                        do
                                                #echo $lib_line
                                                if [[ $lib_line == *"linux-vdso"* ||
                                                      $lib_line == *"libpthread"* ||
                                                      $lib_line == *"libc.so"* ||
                                                      $lib_line == *"ld-linux"* ||
                                                      $lib_line == *"libsctp"* ||
                                                      $lib_line == *"librt.so"* ||
                                                      $lib_line == *"libdl.so"* ||
                                                      $lib_line == *"libz.so"* ||
                                                      $lib_line == *"libstdc++.so"* ||
                                                      $lib_line == *"libm.so"* ||
                                                      $lib_line == *"libgcc_s.so"* ||
                                                      $lib_line == *"libnsl.so"* ||
                                                      $lib_line == *"linux-gate.so"* ||
                                                      $lib_line == *"libresolv.so"* ]]; then
                                                        continue
                                                fi
                                                lib_line=$(echo $lib_line | cut -d ">" -f2 | cut -d "(" -f1)
                                                #ldd_info="$ldd_info,$lib_line"
                                                echo $lib_line >> /tmp/$pod.$cid.ps.lib.list
                                        done < /tmp/$pod.$cid.ps.lib
                                        ldd_info=$(cat /tmp/$pod.$cid.ps.lib.list)
                                        if [[ $ldd_info == "" ]]; then
                                                ldd_info="standard"
                                        fi
                                        rm -rf /tmp/$pod.$cid.ps.lib.list
                                        rm -rf /tmp/$pod.$cid.ps.lib
                                else
                                        ldd_info="dup"
                                fi
                                echo "$pod,$cid,\"$ps_line\",$cmd,\"$ldd_info\"" >> $OUTPUT_NAME
                                echo "+++++++++++++"
                        done < /tmp/$pod.$cid.ps
                        rm -rf /tmp/$pod.$cid
                        rm -rf /tmp/$pod.$cid.ps
                fi
                echo "-------------------------------"
        done
done
