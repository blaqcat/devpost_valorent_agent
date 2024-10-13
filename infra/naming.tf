# locals {
#   policy = {
#     AmazonBedrockFullAccess = {
#       effect    = "Allow"
#       actions   = ["bedrock:*"]
#       resources = ["*"]
#     }
#     AmazonBedrockModelAccess = {
#       effect  = "Allow"
#       actions = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
#       resources = ["arn:aws:bedrock:*::foundation-model/*"]
#     }
#     AmazonBedrockAgentAccess = {
#       effect  = "Allow"
#       actions = [
#         "bedrock:CreateAgent",
#         "bedrock:DeleteAgent",
#         "bedrock:GetAgent",
#         "bedrock:ListAgents",
#         "bedrock:InvokeAgent"
#       ]
#       resources = ["arn:aws:bedrock:*:*:agent/*"]
#     }
#     IAMPassRoleForBedrockAgent = {
#       effect    = "Allow"
#       actions   = ["iam:PassRole"]
#       resources = ["arn:aws:iam::*:role/*"]
#       condition = {
#         test     = "StringEquals"
#         variable = "iam:PassedToService"
#         values   = ["bedrock.amazonaws.com"]
#       }
#     }
#   }
# }



locals {
  policy = {
    AmazonBedrockFullAccess = {
      effect    = "Allow"
      actions   = ["bedrock:*"]
      resources = ["*"]
    }
    AmazonBedrockModelAccess = {
      effect    = "Allow"
      actions   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
      resources = ["arn:aws:bedrock:*::foundation-model/*"]
    }
    AmazonBedrockAgentAccess = {
      effect = "Allow"
      actions = [
        "bedrock:CreateAgent",
        "bedrock:DeleteAgent",
        "bedrock:GetAgent",
        "bedrock:ListAgents",
        "bedrock:InvokeAgent"
      ]
      resources = ["arn:aws:bedrock:*:*:agent/*"]
    }
    IAMPassRoleForBedrockAgent = {
      effect    = "Allow"
      actions   = ["iam:PassRole"]
      resources = ["arn:aws:iam::*:role/*"]
      condition = {
        test     = "StringEquals"
        variable = "iam:PassedToService"
        values   = ["bedrock.amazonaws.com"]
      }
    }
  }
}