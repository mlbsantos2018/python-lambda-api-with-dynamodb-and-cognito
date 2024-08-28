# Desafio Bootcamp Cloud AWS DIO

Este projeto faz parte do desafio do Bootcamp Cloud AWS da DIO e demonstra a criação de uma infraestrutura completa na AWS usando Terraform. A infraestrutura inclui uma API REST criada com o Amazon API Gateway, uma função AWS Lambda, uma tabela DynamoDB e um autorizador Cognito. A API é protegida usando um autorizador Cognito e integrada a uma função Lambda que interage com o DynamoDB.

## Visão Geral dos Componentes

- **AWS Lambda**: Função serverless que processa requisições HTTP e interage com o DynamoDB.
- **Amazon DynamoDB**: Tabela NoSQL usada para armazenar dados recebidos pela função Lambda.
- **Amazon API Gateway**: Serviço que expõe a API REST para o mundo externo, permitindo a interação com a função Lambda.
- **Amazon Cognito**: Serviço de identidade usado para proteger a API com autenticação baseada em token.

## Infraestrutura Criada

1. **Tabela DynamoDB**:
   - Nome: `MyTable`
   - Chave Primária: `id` (String)

2. **Função Lambda**:
   - Nome: `lambda-api-with-dynamodb-and-cognito`
   - Executa o código que interage com o DynamoDB.

3. **API Gateway**:
   - API REST criada para expor a função Lambda.
   - Nome padrão (`MyAPI`).
   - Recurso `myresource` com método `POST` integrado à Lambda.

4. **Autorizador Cognito**:
   - Protege o método `POST` da API com autenticação baseada em tokens Cognito.

## Pré-requisitos

- Conta na AWS com permissões suficientes para criar os recursos mencionados.
- Terraform instalado na máquina local.
- Postman para testar a API.

## Passo a Passo

### 1. Clonar o Repositório

Clone o repositório para a sua máquina local:

```bash
git clone https://github.com/mlbsantos2018/python-lambda-api-with-dynamodb-and-cognito.git
cd python-lambda-api-with-dynamodb-and-cognito
```

### 2. Configurar as Credenciais da AWS

Certifique-se de que suas credenciais da AWS estão configuradas corretamente na sua máquina. Você pode fazer isso usando o AWS CLI:

```bash
aws configure
```

### 3. Criar o Arquivo Zip da Lambda

No diretório do projeto, crie um arquivo .zip contendo o código da função Lambda e mova o zip para o diretório infra:

```bash
cd app
zip lambda_function.zip lambda_function.py
mv lambda_function.zip ../infra/
```

### 4. Executar o Terraform

Navegue para o diretório infra, inicialize o Terraform e aplique o plano para criar a infraestrutura na AWS:

```bash
cd ../infra
terraform init
terraform apply
```

### 5. Testar a API com Postman

Após a infraestrutura ser provisionada, siga os passos abaixo para testar a API usando o Postman:

  1. **Obtenha um token de acesso JWT do Amazon Cognito para autenticar as requisições à API.**
  2. **Configure uma requisição no Postman usando o endpoint da API criado.**
  3. **Adicione o token JWT no cabeçalho de autorização da requisição:**
   - `Authorization: Bearer <seu-token-jwt>`

### 6. Limpar os Recursos

Após testar, é importante limpar os recursos criados para evitar custos. Use o Terraform para destruir a infraestrutura:

```bash
terraform destroy
```
