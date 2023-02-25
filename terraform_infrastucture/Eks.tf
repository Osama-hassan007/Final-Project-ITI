# --------------------------------------"Eks-iam-role"-----------------------------
resource "aws_iam_role" "eks_cluster" {
  name = "eks_cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.eks_cluster.name
}

# --------------------------------------"My-Eks"-----------------------------
resource "aws_eks_cluster" "osos-cluster" {
  name = "osos-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [
        aws_subnet.osos-pub1.id,
        aws_subnet.osos-pub2.id,
        aws_subnet.osos-pv1.id,
        aws_subnet.osos-pv1.id]
    security_group_ids = [aws_security_group.eks.id]
    endpoint_private_access = true
  }

 
}

# --------------------------------------"Iam-role-nodes"-----------------------------

resource "aws_iam_role" "osos-node" {
  name = "example-eks-node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.osos-node.name
}
                                                            # We need to attach some a few policies

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.osos-node.name                             // Grant access to ec2 and eks 
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.osos-node.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.osos-node.name
}
resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.osos-node.name
}

# --------------------------------------"Node-Group"-----------------------------

resource "aws_eks_node_group" "osos-ng" {
  cluster_name    = aws_eks_cluster.osos-cluster.name
  node_group_name = "osos-node-group"
  node_role_arn   = aws_iam_role.osos-node.arn
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  remote_access {
    ec2_ssh_key = "nagato"
  }
  subnet_ids = [
    aws_subnet.osos-pv1.id,
    aws_subnet.osos-pv2.id,
  ]

  instance_types = ["t2.medium"]
}



