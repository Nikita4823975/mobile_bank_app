import mysql.connector
from flask import Flask, jsonify, request, make_response
from flask_cors import CORS
import mysql.connector
import bcrypt
import datetime
from functools import wraps
import re
from hashlib import pbkdf2_hmac
import binascii
import os
import jwt
import uuid
from datetime import datetime, timedelta

def hash_password(password):
    """Генерация хеша пароля"""
    salt = os.urandom(16)
    key = pbkdf2_hmac('sha256', password.encode('utf-8'), salt, 100000)
    return f"{binascii.hexlify(salt).decode()}:{binascii.hexlify(key).decode()}"

# Настройки подключения к БД
db_config = {
    'host': 'localhost',
    'user': 'flutter_user',
    'password': '1234',
    'database': 'mbapp'
}

def update_passwords():
    try:
        # Подключаемся к базе данных
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        # Получаем всех пользователей
        cursor.execute("SELECT user_id, phone_number FROM users")
        users = cursor.fetchall()
        
        # Новый пароль
        new_password = "password"
        
        for user in users:
            user_id, phone_number = user
            print(f"Обновление пароля для пользователя {phone_number} (ID: {user_id})")
            
            # Хешируем новый пароль
            hashed_password = hash_password(new_password)
            
            # Обновляем запись в базе данных
            cursor.execute(
                "UPDATE users SET password_hash = %s WHERE user_id = %s",
                (hashed_password, user_id)
            )
        
        # Фиксируем изменения
        conn.commit()
        print("Все пароли успешно обновлены!")
        
    except mysql.connector.Error as err:
        print(f"Ошибка: {err}")
        
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    update_passwords()