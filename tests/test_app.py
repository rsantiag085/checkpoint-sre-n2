import sys
sys.path.insert(0, '../app')
from app import app
import pytest

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_endpoint(client):
    """Testa se o endpoint principal funciona"""
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert 'message' in data
    assert 'version' in data

def test_health_endpoint(client):
    """Testa se o endpoint de saúde funciona"""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'

def test_request_counter(client):
    """Testa se o contador de requisições funciona (Validando via /metrics)"""
    # 1. Verifica contagem inicial em /metrics
    r_start = client.get('/metrics')
    count_start = r_start.get_json()['total_requests']
    
    # 2. Faz uma requisição na home para incrementar
    client.get('/')
    
    # 3. Verifica contagem final em /metrics
    r_end = client.get('/metrics')
    count_end = r_end.get_json()['total_requests']
    
    assert count_end > count_start