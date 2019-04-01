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
