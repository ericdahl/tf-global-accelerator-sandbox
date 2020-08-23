resource "aws_iam_role" "web" {
  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}

EOF
}


resource "aws_iam_instance_profile" "web" {
  name = "web"
  role = aws_iam_role.web.name
}

resource "aws_iam_policy" "sessions_manager" {
  name   = "sessions-manager-instance"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetEncryptionConfiguration"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*"
    },

    {
      "Effect": "Allow",
      "Action": [
        "ec2messages:GetMessages",
        "ssm:ListAssociations",
        "ssm:ListInstanceAssociations"
      ],
      "Resource": "*"
    }
  ]
}

EOF
}

resource "aws_iam_role_policy_attachment" "web_sessions_manager" {
  policy_arn = aws_iam_policy.sessions_manager.arn
  role       = aws_iam_role.web.name
}
