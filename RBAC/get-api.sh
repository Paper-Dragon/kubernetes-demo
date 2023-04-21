curl -k -H "Authorization: Bearer $(kubectl get secret admin-token-5tctj -n kube-system -o jsonpath={".data.token"} | base64 -d)" https://192.168.23.150:6443/api
