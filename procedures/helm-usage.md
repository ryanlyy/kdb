# 1 Helm Commands
```
helm get manifest releasename: show chart resource of this release
helm install --debug --dry-run --name my-release ./mychart
```
# 2 Helm Objects
Major Built-in Objects: Release, Values, Chart, Files, Capabilities, Template

# 3 Helm Functions
Built-in Functions: quote, repeat, upper, default, eq, ne, lt, gt, and, or etc.

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
Built-in Object: 
* Subchart Name
* global

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
