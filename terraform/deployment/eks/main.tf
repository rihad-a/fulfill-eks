resource "aws_eks_cluster" "main" {
  name = "${var.environment}-${var.cluster_name}"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.private_subnet_ids

    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.eks_public_access_cidrs
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "cluster" {
  name = "${var.environment}-${var.cluster_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Creating the EKS managed node groups in 3 AZs

resource "aws_eks_node_group" "main" {

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-${var.node_group_name}"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "node_group" {
  name = "${var.environment}-${var.node_group_name}-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

# Creating the EKS Pod Identity agent addon

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.4-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    aws_eks_node_group.main
  ]
}

# Granting user access to the EKS cluster

resource "aws_eks_access_entry" "admin_user_access" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.admin_user_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_user_access_policy" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.admin_user_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# EKS networking and DNS addons

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    aws_eks_node_group.main
  ]
}

# Pod Identity Association for SQS

resource "aws_iam_role" "sqs_pod_identity" {
  name = "${var.environment}-${var.sqs_pod_identity_role_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "sqs_pod_identity_policy" {
  name = "${var.environment}-${var.sqs_pod_identity_policy_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          var.worker_queue_arn,
          var.worker_dlq_arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_pod_identity_policy_attachment" {
  policy_arn = aws_iam_policy.sqs_pod_identity_policy.arn
  role       = aws_iam_role.sqs_pod_identity.name
}

resource "aws_eks_pod_identity_association" "sqs_pod_identity_association" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = var.environment
  service_account = var.sqs_pod_identity_service_account
  role_arn        = aws_iam_role.sqs_pod_identity.arn
}