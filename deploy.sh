#!/bin/bash
set -e  ## Para na primeira falha

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Uso: ./deploy.sh <versão>"
    echo "Exemplo: ./deploy.sh 1.0.0"
    exit 1
fi

echo "=== Deploy da versão $VERSION ==="

## 1. Build da nova imagem...
echo "1. Construindo a imagem Docker..."
docker build -t sre-app:$VERSION app/

## 2. Parar o container antigo...
echo "2. Parando o container antigo..."
docker stop sre-app 2>/dev/null || true
docker rm sre-app 2>/dev/null || true

## 3. Salva a versão anterior...
echo "3. Salvando a versão anterior..."
docker tag sre-app:$VERSION sre-app:previous || true

## 4. Iniciar o novo container...
echo "4. Iniciando o nova versão..."
docker run -d -p 8080:8080 --name sre-app \
    -e APP_VERSION=$VERSION \
    sre-app:$VERSION

## 5. Aguardar a inicialização...
echo "5. Aguardando a inicialização da aplicação..."
sleep 5

## 6. Verificar saúde da aplicação...
echo "6. Verificando saúde da aplicação..."
for i in {1..5}; do
    if curl -s http://localhost:8080/health >/dev/null; then
        echo "✓ Deploy concluido com sucesso!"
        echo "Versão $VERSION está rodando."
        exit 0
    fi
        echo "Tentativa $i/5 falhou, aguardando..."
        sleep 2
done   

echo "✗ Falha no deploy. Execute o rollback."
exit 1