terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


python3 -c "
import pika, ssl
context = ssl.create_default_context()
cp = pika.ConnectionParameters(
    host='<TU_ENDPOINT_MQ>',
    port=5671,
    virtual_host='/',
    credentials=pika.PlainCredentials('<USUARIO>', '<PASSWORD>'),
    ssl_options=pika.SSLOptions(context)
)
try:
    conn = pika.BlockingConnection(cp)
    print('✅ CONEXIÓN EXITOSA')
    conn.close()
except Exception as e:
    print(f'❌ ERROR: {e}')
"
