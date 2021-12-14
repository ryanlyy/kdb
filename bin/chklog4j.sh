#$1 <namespace>
NAMESPACE=$1
for pod in $(kubectl get pod -n $NAMESPACE | awk '{ print $1 }');
do
        conts=$(kubectl get pod -n $NAMESPACE $pod -o jsonpath='{ .status.containerStatuses[*].name }')
        for cont in $conts;
        do
                echo "Checking if container $cont in pod $pod has log4j...................."
                kubectl exec -ti $pod -n $NAMESPACE -c $cont -- sh -c 'find / -name "*log4j*" '
                echo "Checking if container $cont in pod $pod has log4j end #####################"
        done
done
