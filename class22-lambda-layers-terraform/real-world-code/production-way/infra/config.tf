locals {

 lambda_info = [
    {
        name = "lambda1",
        path = "../lambdas/lambda1",
        handler = "main.lambda_handler",
        runtime = "python3.12"

        environments_variables = {
            DB_NAME     = "prod_db"
            LAMBDA_USER = "lambda_user"
            LOG_LEVEL   = "info"
        }
        # layers = "layer2"
         layers = ["layer1", "layer2"]
    },
    {
        name = "lambda2",
        path = "../lambdas/lambda2",
        handler = "main.lambda_handler",
        runtime = "python3.12"
        environments_variables = {
            DB_NAME     = "prod_db"
            LAMBDA_USER = "lambda_user"
            LOG_LEVEL   = "info"
        }
        # layers = "layer3"
        layers = ["layer2", "layer3"]
    },
    {
        name = "lambda3",
        path = "../lambdas/lambda3",
        handler = "main.lambda_handler",
        runtime = "python3.12"
        environments_variables = {
            DB_NAME     = "prod_db"
            LAMBDA_USER = "lambda_user"
            LOG_LEVEL   = "info"
        }
        # layers = "layer1"
         layers = ["layer1", "layer3"]
    }
 ]

  lambda_layers = [
    {
      name                = "layer1",
      path              = "../layers/layer1",
      compatible_runtimes = ["python3.12", "python3.11"]
    },
    {
      name                = "layer2",
      path              = "../layers/layer2",
      compatible_runtimes = ["python3.11", "python3.12", "python3.9"]
    },

    {
      name                = "layer3",
      path              = "../layers/layer3",
      compatible_runtimes = ["python3.9", "python3.12"]
    }
  ]

  lambda_layers_map = { for layer in local.lambda_layers : layer.name => layer }
  lambda_info_map = { for lambda in local.lambda_info : lambda.name => lambda }
}