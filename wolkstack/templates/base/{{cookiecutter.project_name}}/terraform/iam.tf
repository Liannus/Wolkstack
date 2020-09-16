#--------------------------------------- Provider ---------------------------------------------
data "tls_certificate" "cluster" {
  url = module.eks.cluster_oidc_issuer_url 
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = concat([data.tls_certificate.cluster.certificates.0.sha1_fingerprint], var.oidc_thumbprint_list)
  url = module.eks.cluster_oidc_issuer_url 
}

#---------------------------------------- Policy ---------------------------------------------
resource "aws_iam_policy" "external_dns_policy" {
  name        = "external_dns_policy"
  path        = "/"
  description = "IAM policy for external DNS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

#--------------------------------------- Role ---------------------------------------------
resource "aws_iam_role" "external_dns_role" {
  name = "external_dns"

  assume_role_policy =  templatefile("oidc_assume_role_policy.json", { OIDC_ARN = aws_iam_openid_connect_provider.cluster.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.cluster.url, "https://", ""), NAMESPACE = "default", SA_NAME = "external-dns" })

  tags = merge(
    var.external_dns_role_tags,
    {
      "ServiceAccountName"      = "external-dns"
      "ServiceAccountNameSpace" = "default"
    }
  )
depends_on = [aws_iam_openid_connect_provider.cluster]
}

#--------------------------------------- Policy Connectors ---------------------------------------------
resource "aws_iam_role_policy_attachment" "attach_external_dns_policy" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns_policy.arn

depends_on = [aws_iam_role.external_dns_role, aws_iam_policy.external_dns_policy]
}

resource "aws_iam_role_policy_attachment" "attach_CNI_policy" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

depends_on = [aws_iam_role.external_dns_role, aws_iam_policy.external_dns_policy]
}

resource "aws_iam_role_policy_attachment" "attach_eks_cluster_policy" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

depends_on = [aws_iam_role.external_dns_role]
}
