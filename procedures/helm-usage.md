# 1 Helm Commands
```
helm get manifest releasename: show chart resource of this release
helm install --debug --dry-run --name my-release ./mychart
```
# 2 Helm Objects
Major Built-in Objects: Release, Values, Chart, Files, Capabilities, Template

# 3 Helm Functions
Built-in Functions: quote, repeat, upper, default, eq, ne, lt, gt, and, or etc.
https://coveo.github.io/gotemplate/index

# 4 Helm Flow Control
```
•	if/else: for creating conditional blocks
{{ if PIPELINE }}
  # Do something
{{ else if OTHER PIPELINE }}
  # Do something else
{{ else }}
  # Default case
{{ end }}
The reason for this is to make it clear that control structures can execute an entire pipeline, not just evaluate a value.

A pipeline is evaluated as false if the value is:
•	a boolean false
•	a numeric zero
•	an empty string
•	a nil (empty or null)
•	an empty collection (map, slice, tuple, dict, array)
Under all other conditions, the condition is true.

•	with: to specify a scope
•	range: which provides a “for each”-style loop

•	define declares a new named template inside of your template
•	template imports a named template
•	block declares a special kind of fillable template area

```
# 5 Values.yaml
Predifined Values:
```

    Release: This object describes the release itself. It has several objects inside of it:
        Release.Name: The release name
        Release.Time: The time of the release
        Release.Namespace: The namespace to be released into (if the manifest doesn’t override)
        Release.Service: The name of the releasing service (always Tiller).
        Release.Revision: The revision number of this release. It begins at 1 and is incremented for each helm upgrade.
        Release.IsUpgrade: This is set to true if the current operation is an upgrade or rollback.
        Release.IsInstall: This is set to true if the current operation is an install.
    Values: Values passed into the template from the values.yaml file and from user-supplied files. By default, Values is empty.
    Chart: The contents of the Chart.yaml file. Any data in Chart.yaml will be accessible here. For example {{.Chart.Name}}-{{.Chart.Version}} will print out the mychart-0.1.0.
        The available fields are listed in the Charts Guide
    Files: This provides access to all non-special files in a chart. While you cannot use it to access templates, you can use it to access other files in the chart. See the section Accessing Files for more.
        Files.Get is a function for getting a file by name (.Files.Get config.ini)
        Files.GetBytes is a function for getting the contents of a file as an array of bytes instead of as a string. This is useful for things like images.
    Capabilities: This provides information about what capabilities the Kubernetes cluster supports.
        Capabilities.APIVersions is a set of versions.
        Capabilities.APIVersions.Has $version indicates whether a version (batch/v1) is enabled on the cluster.
        Capabilities.KubeVersion provides a way to look up the Kubernetes version. It has the following values: Major, Minor, GitVersion, GitCommit, GitTreeState, BuildDate, GoVersion, Compiler, and Platform.
        Capabilities.TillerVersion provides a way to look up the Tiller version. It has the following values: SemVer, GitCommit, and GitTreeState.
    Template: Contains information about the current template that is being executed
        Name: A namespaced filepath to the current template (e.g. mychart/templates/mytemplate.yaml)
        BasePath: The namespaced path to the templates directory of the current chart (e.g. mychart/templates).
```

# 6 hook

* pre-install: Executes after templates are rendered, but before any resources are created in Kubernetes.
```
    User runs helm install foo
    Chart is loaded into Tiller
    After some verification, Tiller renders the foo templates
    Tiller prepares to execute the pre-install hooks (loading hook resources into Kubernetes)
    Tiller sorts hooks by weight (assigning a weight of 0 by default) and by name for those hooks with the same weight in ascending order.
    Tiller then loads the hook with the lowest weight first (negative to positive)
    Tiller waits until the hook is “Ready”
    Tiller loads the resulting resources into Kubernetes. Note that if the --wait flag is set, Tiller will wait until all resources are in a ready state and will not run the post-install hook until they are ready.
    Tiller executes the post-install hook (loading hook resources)
    Tiller waits until the hook is “Ready”
    Tiller returns the release name (and other data) to the client
    The client exits
```
* post-install: Executes after all resources are loaded into Kubernetes
* pre-delete: Executes on a deletion request before any resources are deleted from Kubernetes.
* post-delete: Executes on a deletion request after all of the release’s resources have been deleted.
* pre-upgrade: Executes on an upgrade request after templates are rendered, but before any resources are loaded into Kubernetes (e.g. before a Kubernetes apply operation).
* post-upgrade: Executes on an upgrade after all resources have been upgraded.
* pre-rollback: Executes on a rollback request after templates are rendered, but before any resources have been rolled back.
* post-rollback: Executes on a rollback request after all resources have been modified

# 7 Kubernetest install/uninstall order by kind
```
// InstallOrder is the order in which manifests should be installed (by Kind)
      var InstallOrder SortOrder = []string{"Namespace", "Secret", "ConfigMap", "PersistentVolume", "ServiceAccount", "Service", "Pod", "ReplicationController", "Deployment", "DaemonSet", "Ingress", "Job"} 
17:20 

// UninstallOrder is the order in which manifests should be uninstalled (by Kind)
      var UninstallOrder SortOrder = []string{"Service", "Pod", "ReplicationController", "Deployment", "DaemonSet", "ConfigMap", "Secret", "PersistentVolume", "ServiceAccount", "Ingress", "Job", "Namespace"} 
```
# 8 helm Customer Function Defination and Usage
* Defination
```
[root@bcmt-control01 templates]# cat _helper.tpl
{{- define "my_vnf_name_env" }}
- name: MY_VNF_NAME
  value: *vnfname
{{- end }}

{{- define "test_function" }}
- name: TEST1
  value: {{ .var_abc }}
- name: TEST2
  value: {{ .var_def }}
{{- end }}
```
* Usage
```
     - name: nginx
        image: nginx:1.7.9
        vnfname: &vnfname "abcdfg"
        env:
          {{- include "test_function" (dict "var_abc" "ABC" "var_def" "DEF") | indent 10}}
          {{- include "my_vnf_name_env" . | indent 10 }}
```
* Result
```
spec:
  containers:
  - env:
    - name: TEST1
      value: ABC
    - name: TEST2
      value: DEF
    - name: MY_VNF_NAME
      value: abcdfg
```
# 9 Helm Template Syntax
https://golang.org/pkg/text/template/
kubernetes Resource Spec Syntax
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#-strong-api-overview-strong-

# 10 Helm Packaging
```
set -x
helm delete td-tas01-admin-proxy-0 --purge
helm delete td-tas01-admin-proxy-1 --purge
helm delete td-tas01-dtd-0 --purge
helm delete td-tas01-httplb-oapi-0 --purge
helm delete td-tas01-m3ualb-0 --purge
helm delete td-tas01-m3ualb-1 --purge
helm delete td-tas01-dnsproxy-0 --purge
helm delete td-tas01-dnsproxy-1 --purge

cd  /home/cloud-user/smsf
rm nokia-tas-19.0.23-SMSF-phase3-aaca668.tgz
helm package nokia-tas
cp /home/cloud-user/smsf/nokia-tas-19.0.23-SMSF-phase3-aaca668.tgz /opt/bcmt/storage/charts/.
cd /opt/bcmt/storage
helm repo index charts
ipdcc=$(kubectl get pod | grep ipdcc| awk '{ print $1 }')
kubectl delete pod $ipdcc
kubectl get pod | grep ipdcc| awk '{ print $1 }'
```

# 100 Best Practices
* Chart Name
Not Permit
```
Neither uppercase letters nor underscores should be used in chart names. 
Dots should not be used in chart names.
```
Permit
```
Chart names should use lower case letters and numbers, and start with a letter.
Hyphens (-) are allowed
The directory that contains a chart MUST have the same name as the chart.
```

* Version Number
SemVer2

* Fomatting Yaml
```
YAML files should be indented using two spaces (and never tabs).
```

* Values
   ** Naming
   ```
   Variables names should begin with a lowercase letter, and words should be separated with camelcase:
   
   Note that all of Helm’s built-in variables begin with an uppercase letter to easily distinguish them from user-defined values: .Release.Name, .Capabilities.KubeVersion.
   ```
