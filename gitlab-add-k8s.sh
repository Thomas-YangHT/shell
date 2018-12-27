kubectl create namespace gitlab
kubectl create -f - <<EOF
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: gitlab
    namespace: gitlab
EOF

kubectl create -f - <<EOF
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gitlab-cluster-admin
subjects:
- kind: ServiceAccount
  name: gitlab
  namespace: gitlab
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF
