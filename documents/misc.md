# How to List node taints
```
kubectl get nodes -o json | jq .items[].spec

[root@bcmt-control01 ~]# kubectl get nodes bcmt-control01 -o json  | jq .spec
{
  "taints": [
    {
      "effect": "NoExecute",
      "key": "is_control",
      "value": "true"
    }
  ]
}

```

# How to find rpm package from binary
```
[ryliu@GIT-server sde]$ rpm -qf /usr/bin/ping
iputils-20160308-10.el7.x86_64
[ryliu@GIT-server sde]$
```
