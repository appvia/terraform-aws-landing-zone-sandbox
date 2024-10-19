
locals {
  ## The default cost anomaly detection monitors to apply to the account 
  cost_anomaly_default_monitors = [
    {
      name      = lower("lza-${local.region}")
      frequency = "IMMEDIATE"
      threshold_expression = [
        {
          and = {
            dimension = {
              key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
              match_options = ["GREATER_THAN_OR_EQUAL"]
              values        = ["100"]
            }
          }
        },
        {
          and = {
            dimension = {
              key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
              match_options = ["GREATER_THAN_OR_EQUAL"]
              values        = ["50"]
            }
          }
        }
      ]

      specification = jsonencode({
        "And" : [
          {
            "Dimensions" : {
              "Key" : "REGION"
              "Values" : [local.region]
            }
          }
        ]
      })
    }
  ]
}
