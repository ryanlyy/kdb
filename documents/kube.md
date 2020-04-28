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
# 设置命名空间首选项
```
您可以永久保存该上下文中所有后续 kubectl 命令使用的命名空间。

kubectl config set-context --current --namespace=<insert-namespace-name-here>
# Validate it
kubectl config view | grep namespace:
```
