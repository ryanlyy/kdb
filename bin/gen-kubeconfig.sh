# Create Service Account ${1}
SERVICE_ACCOUNT=$1
kubectl create --namespace kube-system serviceaccount $SERVICE_ACCOUNT
SECRET_NAME=$(kubectl get --namespace kube-system -o jsonpath='{.secrets[0].name}' serviceaccounts $SERVICE_ACCOUNT)
SERVICEACCOUNT_TOKEN=$(kubectl get --namespace kube-system secrets ${SECRET_NAME} -o jsonpath='{.data.token}' | base64 -d)

CLUSTER_NAME=$(kubectl config view -o jsonpath='{.clusters[0].name}')
CLUSTER_SERVER=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_CA_CERTIFICATE=$(kubectl config view --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

KUBERNETES_SERVICE_HOST=$(kubectl get svc kubernetes -o jsonpath='{.spec.clusterIP}')
KUBERNETES_SERVICE_PORT=$(kubectl get svc kubernetes -o jsonpath='{.spec.ports[0].port}')
KUBERNETES_SERVICE_PROTOCOL=$(kubectl get svc kubernetes -o jsonpath='{.spec.ports[0].name}')

# Write a kubeconfig file for the CNI plugin.  Do this
# to skip TLS verification for now.  We should eventually support
# writing more complete kubeconfig files. This is only used
# if the provided CNI network config references it.
SA_KUBECONFIG=/tmp/kubeconf.yaml
touch $SA_KUBECONFIG
chmod ${KUBECONFIG_MODE:-600} $SA_KUBECONFIG

cat > $SA_KUBECONFIG <<EOF
# Kubeconfig file .
apiVersion: v1
kind: Config
current-context: default
clusters:
- cluster:
    certificate-authority-data: ${CLUSTER_CA_CERTIFICATE}
    server: ${KUBERNETES_SERVICE_PROTOCOL:-https}://[${KUBERNETES_SERVICE_HOST}]:${KUBERNETES_SERVICE_PORT}
  name: ${CLUSTER_NAME}
users:
- name: $SERVICE_ACCOUNT
  user:
    token: ${SERVICEACCOUNT_TOKEN}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: $SERVICE_ACCOUNT
  name: default
preferences: {}
EOF

cat $SA_KUBECONFIG
rm -rf $SA_KUBECONFIG
