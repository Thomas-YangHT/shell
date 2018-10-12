https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
https://kubernetes.io/docs/reference/access-authn-authz/rbac/#service-account-permissions

kubectl create -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-robot
  namespace: django-2
EOF

kubectl get serviceaccounts/build-robot -o yaml


kubectl create -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: build-robot-secret
  annotations:
    kubernetes.io/service-account.name: build-robot
type: kubernetes.io/service-account-token
EOF


kubectl describe secrets

kubectl create clusterrolebinding serviceaccounts-gitlab-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=gitlab:default
  
