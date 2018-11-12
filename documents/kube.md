# Node Affinity
```
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: nodetype
            operator: In
            values:
            - infra
            - oam
            - reporting
```
