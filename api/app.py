from flask import Flask, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)  # Разрешаем запросы с фронтенда (Flutter)

# Подключение к базе данных
def get_db_connection():
    conn = mysql.connector.connect(
        host='localhost',
        user='flutter_user',  # пользователь
        password='1234',      # пароль
        database='mbapp'      # имя БД
    )
    return conn

@app.route('/api/phone-numbers', methods=['GET'])
def get_phone_numbers():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute('SELECT phone_number FROM users')
    result = cursor.fetchall()
    conn.close()
    return jsonify(result)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)