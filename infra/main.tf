data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# data "aws_region" "current" {}

data "aws_iam_policy_document" "valorent_agent_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:${data.aws_partition.current.partition}:bedrock:${var.region}:${data.aws_caller_identity.current.account_id}:agent/*"]
      variable = "AWS:SourceArn"
    }
  }
}

# data "aws_iam_policy_document" "valorent_agent_permissions" {
#   statement {
#     actions = ["bedrock:InvokeModel"]
#     resources = [
#       "arn:${data.aws_partition.current.partition}:bedrock:${var.region}::foundation-model/anthropic.claude-v2",
#     ]
#   }
# }

# locals {
#   policy_statements = {
#     AmazonBedrockFullAccess = {
#       effect    = "Allow"
#       actions   = ["bedrock:*"]
#       resources = ["arn:aws:bedrock:us-east-1::foundation-model/us.meta.llama3-2-11b-instruct-v1:0"]
#     }
#     AmazonBedrockModelAccess = {
#       effect    = "Allow"
#       actions   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
#       resources = ["arn:aws:bedrock:us-east-1::foundation-model/us.meta.llama3-2-11b-instruct-v1:0"]
#     }
#     AmazonBedrockAgentAccess = {
#       effect = "Allow"
#       actions = [
#         "bedrock:CreateAgent",
#         "bedrock:DeleteAgent",
#         "bedrock:GetAgent",
#         "bedrock:ListAgents",
#         "bedrock:InvokeAgent",
#         "bedrock:UpdateAgent",
#         "bedrock:CreateAgentActionGroup",
#         "bedrock:DeleteAgentActionGroup",
#         "bedrock:GetAgentActionGroup",
#         "bedrock:ListAgentActionGroups",
#         "bedrock:UpdateAgentActionGroup",
#         "bedrock:CreateAgentAlias",
#         "bedrock:DeleteAgentAlias",
#         "bedrock:GetAgentAlias",
#         "bedrock:ListAgentAliases",
#         "bedrock:UpdateAgentAlias",
#         "bedrock:CreateAgentKnowledgeBase",
#         "bedrock:DeleteAgentKnowledgeBase",
#         "bedrock:GetAgentKnowledgeBase",
#         "bedrock:ListAgentKnowledgeBases",
#         "bedrock:UpdateAgentKnowledgeBase",
#         "bedrock:AssociateAgentKnowledgeBase",
#         "bedrock:DisassociateAgentKnowledgeBase",
#         "bedrock:CreateAgentVersion",
#         "bedrock:DeleteAgentVersion"
#       ]
#       resources = ["arn:aws:bedrock:us-east-1::foundation-model/us.meta.llama3-2-11b-instruct-v1:0"]
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

# data "aws_iam_policy_document" "valorent_agent_permissions" {
#   version = "2012-10-17"

#   dynamic "statement" {
#     for_each = local.policy_statements
#     content {
#       sid       = statement.key
#       effect    = statement.value.effect
#       actions   = statement.value.actions
#       resources = statement.value.resources

#       dynamic "condition" {
#         for_each = can(statement.value.condition) ? [statement.value.condition] : []
#         content {
#           test     = condition.value.test
#           variable = condition.value.variable
#           values   = condition.value.values
#         }
#       }
#     }
#   }
# }

locals {
  policy_statements = {
    AmazonBedrockFullAccess = {
      effect    = "Allow"
      actions   = ["bedrock:*"]
      resources = ["*"]
    }
    AmazonBedrockModelAccess = {
      effect    = "Allow"
      actions   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
      resources = ["arn:aws:bedrock:us-east-1::foundation-model/us.meta.llama3-2-11b-instruct-v1:0"]
    }
    AmazonBedrockAgentAccess = {
      effect = "Allow"
      actions = [
        "bedrock:CreateAgent",
        "bedrock:DeleteAgent",
        "bedrock:GetAgent",
        "bedrock:ListAgents",
        "bedrock:InvokeAgent",
        "bedrock:UpdateAgent",
        "bedrock:CreateAgentActionGroup",
        "bedrock:DeleteAgentActionGroup",
        "bedrock:GetAgentActionGroup",
        "bedrock:ListAgentActionGroups",
        "bedrock:UpdateAgentActionGroup",
        "bedrock:CreateAgentAlias",
        "bedrock:DeleteAgentAlias",
        "bedrock:GetAgentAlias",
        "bedrock:ListAgentAliases",
        "bedrock:UpdateAgentAlias",
        "bedrock:CreateAgentKnowledgeBase",
        "bedrock:DeleteAgentKnowledgeBase",
        "bedrock:GetAgentKnowledgeBase",
        "bedrock:ListAgentKnowledgeBases",
        "bedrock:UpdateAgentKnowledgeBase",
        "bedrock:AssociateAgentKnowledgeBase",
        "bedrock:DisassociateAgentKnowledgeBase",
        "bedrock:CreateAgentVersion",
        "bedrock:DeleteAgentVersion",
        "bedrock:GetInferenceProfile",
        "bedrock:ListInferenceProfiles"
      ]
      resources = ["*"]
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

    BedrockInferenceProfileAccess = {
      effect = "Allow"
      actions = [
        "bedrock:GetInferenceProfile",
        "bedrock:ListInferenceProfiles",
        "bedrock:CreateInferenceProfile",
        "bedrock:DeleteInferenceProfile",
        "bedrock:UpdateInferenceProfile"
      ]
      resources = ["*"]
    }
  }
}

data "aws_iam_policy_document" "valorent_agent_permissions" {
  version = "2012-10-17"

  dynamic "statement" {
    for_each = local.policy_statements
    content {
      sid       = statement.key
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = can(statement.value.condition) ? [statement.value.condition] : []
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}



resource "aws_iam_role" "valorent" {
  assume_role_policy = data.aws_iam_policy_document.valorent_agent_trust.json
  name_prefix        = "AmazonBedrockExecution_Terraform"
}

resource "aws_iam_role_policy" "valorent" {
  policy = data.aws_iam_policy_document.valorent_agent_permissions.json
  role   = aws_iam_role.valorent.id
}

resource "aws_bedrockagent_agent" "valorent" {
  agent_name                  = "dev-post-valorent"
  agent_resource_role_arn     = aws_iam_role.valorent.arn
  idle_session_ttl_in_seconds = 500
  # foundation_model            = "anthropic.claude-v2"
  foundation_model = "us.meta.llama3-2-11b-instruct-v1:0"
  instruction = <<-EOT
    You are hired as a data scientist on a new VALORANT Esports team and have been tasked by the team's general manager to support the scouting and recruitment process. Your role is to act as a LLM-powered digital assistant to build teams and answer various questions about VALORANT Esports players.

    Key Information:
    - VALORANT is a tactical FPS game developed by Riot Games.
    - The game combines precise gunplay with unique agent abilities in a strategic 5v5 format.
    - The VALORANT Champions Tour (VCT) is the official esports league for the game.
    - VCT features regional qualifiers, leagues, and culminates in a global championship.

    Your Tasks:
    1. Provide insights on player statistics and performance metrics.
    2. Analyze team compositions and suggest optimal agent selections.
    3. Offer strategic advice based on map knowledge and meta trends.
    4. Answer questions about player histories, team transfers, and tournament results.
    5. Assist in identifying promising talent for recruitment.

    Guidelines:
    - Always provide accurate and up-to-date information.
    - When discussing players or teams, consider both individual skill and team synergy.
    - If asked about information you're not certain about, acknowledge the limitation and suggest where to find more reliable data.
    - Maintain a professional and analytical tone in your responses.
  EOT
}