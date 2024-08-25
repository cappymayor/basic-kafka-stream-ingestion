# Dedicated IAM role to be assumed/used by our Redshift cluster
resource "aws_iam_role" "redshift_role" {
  name = "redshift_dedicated_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = {
    service = "Redshift"
    team    = "Core-Data-Engineers"
    env     = "dev"
  }
}

# IAM policy that highlights permission of what Redshift can do
resource "aws_iam_policy" "redshift_policy" {
  name        = "redshift_dedicated_policy"
  description = "Redshift iam policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:List*",
          "s3:get*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::random-profile-extraction",
          "arn:aws:s3:::random-profile-extraction/*"
        ]
      },
      {
        Action = [
          "glue:*Database*",
          "glue:*Table*"
        ]
        Effect = "Allow"
        Resource = [
          "*"
        ]
      }

    ]
  })
}

# Bind the role and policy above together
resource "aws_iam_role_policy_attachment" "role_policy_attach" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = aws_iam_policy.redshift_policy.arn
}

# create random admin password to be used for redshift.
resource "random_password" "password" {
  length  = 24
  special = false
}

# Retrieving an already existing username in AWS SSM parameter store
data "aws_ssm_parameter" "redshift_admin_username" {
  name = "/dev/redshift/redshift_admin_username"
}

# Saving the output of the password generated from line 50 above to SSM parameter store 
resource "aws_ssm_parameter" "redshift_admin_password" {
  name  = "/dev/redshift/redshift_admin_password"
  type  = "String"
  value = random_password.password.result
}

# Create Redshift cluster
resource "aws_redshift_cluster" "core_data_engineers_cluster" {
  cluster_identifier  = "core-data-engineers-cluster"
  database_name       = "core_data_engineers"
  master_username     = data.aws_ssm_parameter.redshift_admin_username.value
  master_password     = aws_ssm_parameter.redshift_admin_password.value
  node_type           = "dc2.large"
  cluster_type        = "multi-node"
  number_of_nodes     = 2
  publicly_accessible = true # There is a layer of security with the cluster despite this being true
  skip_final_snapshot = true # False is recommended in production
  iam_roles           = [aws_iam_role.redshift_role.arn]

  tags = {
    team = "core-data-engineers"
    env  = "dev"
  }
}
