#/usr/bin/bash
POD_LIST=$(kubectl get pod  |grep -v NAME |  awk ' { print $1 } ')
NODE_IPS=($(kubectl get pod -o wide |grep -v NAME  | awk ' { print $NF } '))
echo "###################################################################################################################"
echo "INDEX     NODEIP          POD                               INTERFACE       IP ADDR"
echo "-------------------------------------------------------------------------------------------------------------------"
typeset -i IPS_INDEX
IPS_INDEX=0
for pod in $POD_LIST; do
        kubectl exec -ti $pod ip addr > ./tmp.ip
        INTF_LIST=$(grep BROADCAST ./tmp.ip | cut -d ":" -f 2|cut -d "@" -f 1)
        for intf in $INTF_LIST; do
                IPADDR=$(grep $intf ./tmp.ip | grep inet|cut -d "/" -f1 | cut -d "t" -f 2)
                echo "$IPS_INDEX        ${NODE_IPS[IPS_INDEX]}              $pod                      $intf   $IPADDR";
        done
        IPS_INDEX=$IPS_INDEX+1
echo "-------------------------------------------------------------------------------------------------------------------"
done

echo "###################################################################################################################"
