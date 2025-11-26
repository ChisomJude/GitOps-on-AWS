from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return f"Hello from GitOps on AWS! Running on pod: {os.environ.get('HOSTNAME', 'local')}"

@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
