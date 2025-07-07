import mysql.connector
from hashlib import pbkdf2_hmac
import binascii
import os
from getpass import getpass

def hash_password(password):
    """Генерация хеша пароля с использованием PBKDF2"""
    salt = os.urandom(16)
    key = pbkdf2_hmac('sha256', password.encode('utf-8'), salt, 100000)
    return f"{binascii.hexlify(salt).decode()}:{binascii.hexlify(key).decode()}"

def get_db_connection():
    """Установка соединения с базой данных"""
    return mysql.connector.connect(
        host='localhost',
        user='flutter_user',
        password='1234',
        database='mbapp'
    )

def migrate_passwords():
    print("=== Миграция паролей пользователей ===")
    
    # Запрос учетных данных БД для безопасности
    db_user = input("Введите пользователя БД [flutter_user]: ") or "flutter_user"
    db_pass = getpass("Введите пароль БД [1234]: ") or "1234"
    
    try:
        # Подключаемся к базе данных
        conn = mysql.connector.connect(
            host='localhost',
            user=db_user,
            password=db_pass,
            database='mbapp'
        )
        cursor = conn.cursor(dictionary=True)

        # 1. Изменяем тип столбца password_hash
        print("\n[1/3] Изменяем тип столбца password_hash...")
        cursor.execute("""
            ALTER TABLE users 
            MODIFY password_hash VARCHAR(120) NOT NULL 
            COMMENT 'Формат: salt:key в hex'
        """)
        print("Тип столбца успешно изменен")

        # 2. Получаем всех пользователей
        print("\n[2/3] Получаем список пользователей...")
        cursor.execute("SELECT user_id, phone_number FROM users")
        users = cursor.fetchall()
        print(f"Найдено {len(users)} пользователей")

        # 3. Обновляем пароли
        print("\n[3/3] Обновляем пароли пользователей...")
        default_password = getpass("Введите новый пароль для всех пользователей: ")
        
        for user in users:
            hashed_password = hash_password(default_password)
            cursor.execute(
                "UPDATE users SET password_hash = %s WHERE user_id = %s",
                (hashed_password, user['user_id'])
            )
            print(f"Обновлен пользователь {user['phone_number']} (ID: {user['user_id']})")

        # Применяем изменения
        conn.commit()
        print("\nМиграция успешно завершена!")
        print(f"Все пользователи теперь имеют пароль: {default_password}")

    except mysql.connector.Error as err:
        print(f"\nОшибка MySQL: {err}")
    except Exception as e:
        print(f"\nОшибка: {e}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            conn.close()
            print("Соединение с БД закрыто")

if __name__ == "__main__":
    migrate_passwords()