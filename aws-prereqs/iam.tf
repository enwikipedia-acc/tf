
resource "aws_iam_instance_profile" "ssm" {
  name = "${var.project}-ssm"
  role = aws_iam_role.ssm.name
}

resource "aws_iam_role" "ssm" {
  name               = "${var.project}-ssm"
  assume_role_policy = data.aws_iam_policy_document.assumerole.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = data.aws_iam_policy.ssm_core.arn
}

resource "aws_iam_role_policy_attachment" "ssm_patch" {
  role       = aws_iam_role.ssm.name
  policy_arn = data.aws_iam_policy.ssm_patch.arn
}

data "aws_iam_policy" "ssm_patch" {
  name = "AmazonSSMPatchAssociation"
}

data "aws_iam_policy" "ssm_core" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "assumerole" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type ="Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}