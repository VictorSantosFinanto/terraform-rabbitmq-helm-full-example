
# 🛠️ README – Deploy e Testes da Infraestrutura Kubernetes com API Gateway e RabbitMQ

## ✅ Pré-requisitos

- Conta no **Google Cloud Platform (GCP)** com faturamento ativo
- Ferramentas instaladas localmente:
  - `gcloud`
  - `terraform`
  - `kubectl`
  - `helm`
  - `curl` (para testes)

---

## 🚀 Passo a Passo para Deploy

### 1. Autenticação no GCP
```bash
gcloud auth login
gcloud config set project [SEU_PROJECT_ID]
```

### 2. Provisionar infraestrutura com Terraform
No diretório `/terraform`:
```bash
terraform init
terraform apply -auto-approve
```
Isso criará:
- VPC personalizada
- Sub-rede
- Cluster GKE

### 3. Deploy do RabbitMQ com Helm
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install meu-rabbitmq bitnami/rabbitmq -f helm/rabbitmq-values.yaml
```

### 4. Deploy da API de exemplo
```bash
kubectl apply -f k8s/api-deployment.yaml
kubectl apply -f k8s/api-service.yaml
```

### 5. Deploy do Caddy como API Gateway
```bash
kubectl apply -f caddy-proxy/caddy-config.yml
kubectl apply -f caddy-proxy/caddy-svc.yml
kubectl apply -f caddy-proxy/caddy.yml
```

---

## 🧪 Instruções de Teste

### Com Token Básico (Basic Auth)
```bash
curl -u admin:admin http://[IP_EXTERNO]/api
```

### Sem Token (espera-se erro 401)
```bash
curl http://[IP_EXTERNO]/api
```

### Com JWT (caso configurado)
```bash
curl -H "Authorization: Bearer <seu_jwt>" http://[IP_EXTERNO]/api
```

---

## 🔍 Como Validar o RabbitMQ

1. Encaminhe a porta para acessar localmente:
```bash
kubectl port-forward svc/meu-rabbitmq 15672:15672
```

2. Acesse via navegador:
```
http://ip-cluste-ou-load-balancer-ou-fastfoward:15672
```
- Usuário e senha podem estar no `rabbitmq-values.yaml`.

3. Para testar filas:
```bash
kubectl exec -it [pod_do_rabbitmq] -- rabbitmqctl list_queues
```

---

## 📐 Justificativas Arquiteturais

- **GKE (Google Kubernetes Engine)**: solução gerenciada que reduz overhead operacional.
- **Caddy como API Gateway**: escolhido pela simplicidade de configuração de autenticação básica e HTTPS automático.
- **RabbitMQ via Helm**: facilita upgrades e configuração rápida via valores customizados.
- **Infra como código (Terraform + Helm)**: garante reprodutibilidade e versionamento da infraestrutura.
- **Segurança**: autenticação via Basic ou JWT garante controle de acesso; GKE com VPC dedicada limita exposição.
