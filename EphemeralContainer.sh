# Container-1 无bash/sh
#
# Container-2 无bash/sh
#
# Container-3 无bash/sh
#
# 临时容器 具有Debug工具 
#  |  
#  |  |
#  |  share ProcessNameSpace 1.16+
#  |
# Pod Running/Crash
#

# K8s 1.16+ https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/
# K8s 1.18+ kubectl alpha debug redis-new-5b577b46c7-2jv4j -ti --image=registry.cn-beijing.aliyuncs.com/dotbalo/debug-tools
# K8s 1.20+ kubectl debug redis-new-5b577b46c7-2jv4j -ti --image=registry.cn-beijing.aliyuncs.com/dotbalo/debug-tools
kubectl debug node/k8s-node01 -it --image=registry.cn-beijing.aliyuncs.com/dotbalo/debug-tools
# 共享内存me名称空间  --copy-to=<container name>
kubectl debug -n kube-system pod/coredns-567c556887-6qkpz -it --image=ubuntu "??--share-processes??" --copy-to=app-debuc
cat /proc/8/root/etc/nginx/conf.d/default.conf

# 需要注意的node会挂载在/host下
# –share-processes=true只有在copy是才生效


#    --share-processes=true:
#        When used with '--copy-to', enable process namespace sharing in the copy.


