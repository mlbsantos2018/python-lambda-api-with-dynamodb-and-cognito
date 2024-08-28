provider "aws" {
  region = "sa-east-1"
}

# Criação da Tabela no DynamoDB
resource "aws_dynamodb_table" "my_table" {
  name           = "MyTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "MyTable"
  }
}

# Criação da Role e Políticas para o Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:*",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
    ],
  })
}

# Criação da Função Lambda com nome específico
resource "aws_lambda_function" "my_lambda" {
  function_name = "lambda-api-with-dynamodb-and-cognito"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_function.zip"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.my_table.name
    }
  }
}

# Criação da API Gateway REST com nome padrão
resource "aws_api_gateway_rest_api" "my_api" {
  name = "MyAPI"
}

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "myresource"
}

resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.my_resource.id
  http_method             = aws_api_gateway_method.my_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.my_lambda.invoke_arn
}

# Permissão para o API Gateway invocar a Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

# Criação do Amazon Cognito User Pool
resource "aws_cognito_user_pool" "my_user_pool" {
  name = "MyUserPool"
}

# Criação do Autorizador Cognito no API Gateway
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name          = "MyCognitoAuthorizer"
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.my_user_pool.arn]
}

# Método protegido pela autorização do Cognito
resource "aws_api_gateway_method" "secured_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}
