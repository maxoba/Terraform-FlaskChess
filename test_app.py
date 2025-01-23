import pytest
from app import app

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_home(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b"Hello, Flask!" in response.data

def test_add_numbers(client):
    response = client.get('/add')
    assert response.status_code == 200
    assert b"Add Numbers" in response.data

    data = {'num1': 2, 'num2': 3}
    response = client.post('/add', data=data)
    assert response.status_code == 200
    assert b"The sum is: 5" in response.data
