import json
import boto3
import os

# Inicializa o cliente do DynamoDB na região sa-east-1
dynamodb = boto3.resource('dynamodb', region_name='sa-east-1')
table_name = os.environ.get('TABLE_NAME')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Extrai o corpo da requisição (assumindo JSON)
        body = json.loads(event.get('body', '{}'))

        # Gera um ID para o item
        item_id = body.get('id', '123')

        # Cria o item a ser inserido no DynamoDB
        item = {
            'id': item_id,
            'data': body.get('data', 'Hello World'),
            'timestamp': int(context.timestamp)
        }

        # Insere o item na tabela do DynamoDB
        table.put_item(Item=item)

        # Retorna uma resposta de sucesso
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Item inserido com sucesso!', 'item': item})
        }

    except Exception as e:
        # Retorna uma resposta de erro
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Erro ao inserir item', 'error': str(e)})
        }
