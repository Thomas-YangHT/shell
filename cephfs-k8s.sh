一，获取admin的密文
docker exec mon ceph-authtool --print-key /etc/ceph/ceph.client.admin.keyring
二，将之用base64编码
echo "sdfdsadfasdfasdf=" | base64
三，生成并应用k8s secret文件
apiVersion: v1
kind: Secret
metadata:
    name: ceph-secret
data:
    key: QVsdfsadfsadfPQo=
kubectl apply -f ceph-secret
四，编辑deploy文件，挂载cephfs
volumes:
        - name: applog
          hostPath:
            path: / apache/applogs
        - name: nfs4app
          nfs:
            server: 1.2.3.181
            path: /app/BB
        - name: ceph-vol
          cephfs:
            monitors:
            - 1.2.3.4:6789
            user: admin
            secretRef:
              name: ceph-secret
            readOnly: false