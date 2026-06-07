# ==========================================
# Variables
# ==========================================
DOCKER_USERNAME ?= mostafizurrahman24
REGION          ?= ap-southeast-1
CLUSTER_NAME    ?= todo-cluster
ZONES           ?= ap-southeast-1a,ap-southeast-1b
NAMESPACE       ?= todo-app
KUBECTL_VERSION ?= 1.22.6

# ==========================================
# Help
# ==========================================
.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ==========================================
# Prerequisites
# ==========================================
.PHONY: install-kubectl
install-kubectl: ## Install kubectl
	sudo curl --silent --location -o /usr/local/bin/kubectl \
	  https://s3.us-west-2.amazonaws.com/amazon-eks/$(KUBECTL_VERSION)/2022-03-09/bin/linux/amd64/kubectl
	sudo chmod +x /usr/local/bin/kubectl
	kubectl version --client

.PHONY: install-eksctl
install-eksctl: ## Install eksctl
	curl --silent --location \
	  "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(shell uname -s)_amd64.tar.gz" \
	  | tar xz -C /tmp
	sudo mv /tmp/eksctl /usr/local/bin
	eksctl version

# ==========================================
# Infrastructure (EKS)
# ==========================================
.PHONY: create-cluster
create-cluster: ## Create EKS cluster and node group
	eksctl create cluster \
	  --name $(CLUSTER_NAME) \
	  --version 1.35 \
	  --region $(REGION) \
	  --zones $(ZONES) \
	  --without-nodegroup
	eksctl create nodegroup \
	  --cluster=$(CLUSTER_NAME) \
	  --name=todo-nodes \
	  --region=$(REGION) \
	  --node-type=t3.medium \
	  --managed \
	  --nodes=2 \
	  --nodes-min=2 \
	  --nodes-max=3
	aws eks update-kubeconfig --name $(CLUSTER_NAME) --region $(REGION)
	kubectl get nodes

# ==========================================
# Application (Docker & K8s)
# ==========================================
.PHONY: clone
clone: ## Clone the repository
	git clone https://github.com/mostafizur-raahman/Deploying-a-Full-Stack-Application-on-EKS.git

.PHONY: local-up
local-up: ## Run docker compose locally
	docker compose up -d

.PHONY: build-and-push
build-and-push: ## Build and push Docker images to Docker Hub
	docker build -t $(DOCKER_USERNAME)/todo-backend-flask:latest ./backend
	docker push $(DOCKER_USERNAME)/todo-backend-flask:latest
	docker build -t $(DOCKER_USERNAME)/todo-frontend-react:latest ./frontend
	docker push $(DOCKER_USERNAME)/todo-frontend-react:latest

.PHONY: deploy
deploy: ## Deploy application to Kubernetes
	kubectl create namespace $(NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -f k8s/postgres.yaml -n $(NAMESPACE)
	kubectl apply -f k8s/backend.yaml -n $(NAMESPACE)
	kubectl apply -f k8s/frontend.yaml -n $(NAMESPACE)

.PHONY: status
status: ## Check deployment status (pods and services)
	kubectl get pods -n $(NAMESPACE)
	kubectl get svc -n $(NAMESPACE)

.PHONY: get-url
get-url: ## Get the external URL of the frontend
	@echo "Waiting for LoadBalancer..."
	@APP_URL=$$(kubectl get svc frontend -n $(NAMESPACE) -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'); \
	echo "Application URL: http://$$APP_URL"

.PHONY: test
test: ## Test the deployment endpoints
	@APP_URL=$$(kubectl get svc frontend -n $(NAMESPACE) -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'); \
	echo "Testing health check..."; \
	curl -s http://$$APP_URL/health; \
	echo "\nCreating a todo..."; \
	curl -s -X POST http://$$APP_URL/api/todos \
	  -H "Content-Type: application/json" \
	  -d '{"title":"Learn Kubernetes"}'; \
	echo "\nListing todos..."; \
	curl -s http://$$APP_URL/api/todos; \
	echo ""

# ==========================================
# Cleanup
# ==========================================
.PHONY: clean
clean: ## Delete the EKS cluster to avoid AWS charges
	eksctl delete cluster --name $(CLUSTER_NAME) --region $(REGION)

.PHONY: clean-k8s
clean-k8s: ## Delete Kubernetes resources (namespace)
	kubectl delete namespace $(NAMESPACE)