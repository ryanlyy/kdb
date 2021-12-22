if [[ ! $# -eq 2 ]]; then
	echo "Usage: $0 <namespace> <'cmd'>"
	exit 255
fi
NAMESPACE=$1
CMD='$2'
echo "NAMESPACE: $NAMESPACE; CMD: $CMD"
for pod in $(kubectl get pod -n $NAMESPACE | grep -v NAME | awk '{ print $1 }');
do
	conts=$(kubectl get pod -n $NAMESPACE $pod -o jsonpath='{ .status.containerStatuses[*].name }')
	for cont in $conts;
	do
		echo "Run CMD ($CMD) in Container $cont of Pod $pod Start ...................."
		kubectl exec -ti $pod -n $NAMESPACE -c $cont -- sh -c 'find / -name "*java*" 2>&1 | grep -v "Permission"'
		echo "Run CMD ($CMD) in Container $cont of Pod $pod End #####################"
	done
done
