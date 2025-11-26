# GitOps on AWS: ArgoCD + EKS + CodeCommit/CodePipeline

This project demonstrates a production-grade GitOps workflow on AWS using ArgoCD, Amazon EKS, and AWS CodeCommit/CodePipeline.

## Architecture

1.  **Infrastructure**: Provisioned via Terraform (VPC, EKS, ECR).
2.  **Source Code**: Hosted in AWS CodeCommit.
3.  **CI Pipeline**: AWS CodePipeline + CodeBuild builds the Docker image, pushes to ECR, and updates the Helm chart in the Git repo.
4.  **CD Controller**: ArgoCD running in EKS monitors the Git repo and syncs changes to the cluster.

## Prerequisites

-   AWS CLI configured with Administrator permissions.
-   Terraform installed (v1.0+).
-   kubectl installed.
-   Helm installed.
-   Git installed.

## Project Structure

-   `infrastructure/terraform`: Terraform code for AWS resources.
-   `app/`: Sample Python Flask application.
-   `gitops/`: Helm charts and ArgoCD application manifests.
-   `pipeline/`: Buildspec for CodeBuild.

## Deployment Steps

### 1. Provision Infrastructure

Navigate to the terraform directory and apply the configuration:

```bash
cd infrastructure/terraform
terraform init
terraform apply -auto-approve
```

This will create the VPC, EKS cluster, and ECR repository. Note the outputs (Cluster Name, ECR URL).

### 2. Configure kubectl

Update your kubeconfig to interact with the new cluster:

```bash
aws eks update-kubeconfig --region <REGION> --name <CLUSTER_NAME>
```

### 3. Install ArgoCD

Install ArgoCD into the cluster:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Access the ArgoCD UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Login with username 'admin' and password (get it via kubectl)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### 4. Setup CodeCommit and Push Code

Create a CodeCommit repository named `gitops-on-aws` and push this entire project to it.

### 5. Setup CodePipeline

Manually create a CodePipeline in the AWS Console (or automate via Terraform if extended) that:
-   Source: CodeCommit (`gitops-on-aws` repo, `main` branch).
-   Build: CodeBuild using `pipeline/buildspec.yml`.
    -   **Environment Variables**: `AWS_ACCOUNT_ID`, `IMAGE_REPO_NAME` (from Terraform output).
    -   **Permissions**: Ensure CodeBuild role has ECR push and CodeCommit write permissions.

### 6. Deploy Application via ArgoCD

Apply the ArgoCD Application manifest:

```bash
kubectl apply -f gitops/argocd-app.yaml
```

ArgoCD will now sync the Helm chart from the `gitops/charts/webapp` directory to the `default` namespace.

## GitOps Workflow

1.  Make a change to `app/app.py`.
2.  Commit and push to `main`.
3.  CodePipeline triggers -> Builds new image -> Pushes to ECR -> Updates `values.yaml` with new tag -> Commits back to repo.
4.  ArgoCD detects the change in `values.yaml` and syncs the new image to the EKS cluster.

## Cleanup

To destroy the infrastructure:

```bash
cd infrastructure/terraform
terraform destroy -auto-approve
```
