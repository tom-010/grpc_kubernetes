cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: go-grpc-greeter-server
  name: go-grpc-greeter-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: go-grpc-greeter-server
  template:
    metadata:
      labels:
        app: go-grpc-greeter-server
    spec:
      containers:
      - image: localhost:3200/go-grpc-greeter-server
        resources:
          limits:
            cpu: 100m
            memory: 100Mi
          requests:
            cpu: 50m
            memory: 50Mi
        name: go-grpc-greeter-server
        ports:
        - containerPort: 50051
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app: go-grpc-greeter-server
  name: go-grpc-greeter-server
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 50051
  selector:
    app: go-grpc-greeter-server
  type: ClusterIP
EOF

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "GRPC"
  name: fortune-ingress
  namespace: default
spec:
  ingressClassName: nginx
  rules:
  - host: grpctest.dev.mydomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: go-grpc-greeter-server
            port:
              number: 80
  tls:
  # This secret must exist beforehand
  # The cert must also contain the subj-name grpctest.dev.mydomain.com
  # https://github.com/kubernetes/ingress-nginx/blob/master/docs/examples/PREREQUISITES.md#tls-certificates
  - secretName: wildcard.dev.mydomain.com
    hosts:
      - grpctest.dev.mydomain.com
EOF