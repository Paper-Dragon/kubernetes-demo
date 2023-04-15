#  Taints And Toleration

 

## 生产环境的调度并非随便

- Master节点:  **node-role.kubernetes.io/master:NoSchedule**
  - Kube-Proxy、Kube-ControllerManager、Kube-APIServer、Calico、Metrics-Server、Dashboard、其他类型的Pod不要部署到我身上
- 新增节点 **node-role.kubernetes.io/new-node:NoExecute**   **node-role.kubernetes.io/new-node: NoSchedule**
  - 我还没有经过完整的可用性测试，不能部署Pod到我身上
- 维护节点 **node-role.kubernetes.io/maintain:NoExecute**
  - 我要进行维护/升级了，需要将Pod提前迁移到其他节点
- 特殊节点 （SSD/GPU） **node-role.kubernetes.io/ssd:PreferNoSchedule**
  - 我很昂贵，不能随便一个Pod都能部署到我身上

> 设计理念：Taint在一类服务器上打上污点，让不能容忍这个污点的Pod不能部署在打了污点的服务器上。Toleration是让Pod容忍节点上配置的污点，可以让一些需要特殊配置的Pod能够调用到具有污点和特殊配置的节点上

创建一个污点（一个节点可以有多个污点）：

```bash
kubectl taint nodes NODE_NAME TAINT_KEY=TAINT_VALUE:EFFECT
比如：
kubectl taint nodes k8s-node01 ssd=true:PreferNoSchedule
```

- NoSchedule：禁止调度到该节点，已经在该节点上的Pod不受影响
- NoExecute：禁止调度到该节点，如果不符合这个污点，会立马被驱逐（或在一段时间后）
- PreferNoSchedule：尽量避免将Pod调度到指定的节点上，如果没有更合适的节点，可以部署到该节点



## 内置污点

- node.kubernetes.io/not-ready：节点未准备好，相当于节点状态Ready的值为False。
- node.kubernetes.io/unreachable：Node Controller访问不到节点，相当于节点状态Ready的值为Unknown。
- node.kubernetes.io/out-of-disk：节点磁盘耗尽。
- node.kubernetes.io/memory-pressure：节点存在内存压力。
- node.kubernetes.io/disk-pressure：节点存在磁盘压力。
- node.kubernetes.io/network-unavailable：节点网络不可达。
- node.kubernetes.io/unschedulable：节点不可调度。
- node.cloudprovider.kubernetes.io/uninitialized：如果Kubelet启动时指定了一个外部的cloudprovider，它将给当前节点添加一个Taint将其标记为不可用。在cloud-controller-manager的一个controller初始化这个节点后，Kubelet将删除这个Taint。

## Toleration 匹配方法

- 完全匹配

  ```yaml
  tolerations: 
  - keys: taintKey
    operator: Equal
    value: taintValue
    effect: NoSchedule
  ```

- 不完全匹配

  ```yaml
  tolerations:
  - key: taintKey
    operator: Exists
    effect: NoSchedule
  ```

  

- 大范围匹配

  ```yaml
  - key: "node.kubernetes.io/not-ready" # 内置污点
    operator: Exists
    
    # 匹配所有
  - operator: Exists
  ```

  



## 节点宕机快速恢复业务应用

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx-toleration
  name: nginx-toleration
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-toleration
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx-toleration
    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80
        resources: {}
      tolerations: # 跟nodeSelector必须都有才能调度到指定节点
        - key: ssd
          value: "true"
          effect: PreferNoSchedule
          operator: Equal
      nodeSelector:
        ssd: "true"
status: {}




```



## Taint命令常用示例

创建一个污点（一个节点可以有多个污点）：
	kubectl taint nodes NODE_NAME TAINT_KEY=TAINT_VALUE:EFFECT
比如：
	kubectl taint nodes k8s-node01 ssd=true:PreferNoSchedule
查看一个节点的污点：
	kubectl get node k8s-node01 -o go-template --template {{.spec.taints}}
	kubectl describe node k8s-node01 | grep Taints -A 10
删除污点（和label类似）：
	基于Key删除： kubectl taint nodes k8s-node01 ssd-
	基于Key+Effect删除： kubectl taint nodes k8s-node01 ssd:PreferNoSchedule-
修改污点（Key和Effect相同）：
	kubectl taint nodes k8s-node01 ssd=true:PreferNoSchedule --overwrite
