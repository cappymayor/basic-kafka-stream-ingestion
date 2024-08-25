# create a dedicated user for consumer app
resource "aws_iam_user" "data_consumer_user" {
  name = "data_consumer"

  tags = {
    service     = "data_consumer"
    environment = "dev"
  }
}

# Create aws access key and secret key for consumer to programatically interact with AWS
resource "aws_iam_access_key" "data_consumer_credentials" {
  user = aws_iam_user.data_consumer_user.name
}

# saving the output of the access key into AWS SSM parameters store
resource "aws_ssm_parameter" "data_consumer_access_key" {
  name  = "/dev/data_consumer/access_key"
  type  = "String"
  value = aws_iam_access_key.data_consumer_credentials.id
}

# saving the output of the secret key into AWS SSM parameters store
resource "aws_ssm_parameter" "airflow_secret_key" {
  name  = "/dev/data_consumer/secret_key"
  type  = "String"
  value = aws_iam_access_key.data_consumer_credentials.secret
}

# defining AWS IAM policy which highlight what the consumer user can do and cant in AWS
resource "aws_iam_policy" "data_consumer_policy" {
  name        = "data-consumer-policy"
  description = "Dedicated policy for data consumer app "

  # read and write permission 
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:*Object*",
        ]
        Resource = [
          "arn:aws:s3:::random-profile-extraction",
          "arn:aws:s3:::random-profile-extraction/*",
        ]
      },
    ]
  })
}

# attach the IAM policy to airflow user 
resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.data_consumer_user.name
  policy_arn = aws_iam_policy.data_consumer_policy.arn
}
