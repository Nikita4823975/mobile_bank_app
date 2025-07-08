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

# Конфигурация JWT
JWT_SECRET = 'your_very_strong_secret_key_here'
JWT_ALGORITHM = 'HS256'
JWT_EXP_DELTA_SECONDS = 24 * 60 * 60  # 1 день
FLASK_DEBUG = 1

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})
app.config['SECRET_KEY'] = JWT_SECRET  # Секретный ключ для JWT

# Подключение к базе данных
def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host='localhost',
            user='flutter_user',
            password='1234',
            database='mbapp'
        )
        print("Database connection successful")
        return conn
    except mysql.connector.Error as err:
        print(f"Database connection error: {err}")
        raise

def hash_password(password):
    """Генерация хеша пароля"""
    salt = os.urandom(16)
    key = pbkdf2_hmac('sha256', password.encode('utf-8'), salt, 100000)
    return f"{binascii.hexlify(salt).decode()}:{binascii.hexlify(key).decode()}"

def verify_password(stored_hash, provided_password):
    """Проверка пароля"""
    try:
        salt_hex, key_hex = stored_hash.split(':')
        salt = binascii.unhexlify(salt_hex)
        stored_key = binascii.unhexlify(key_hex)

        new_key = pbkdf2_hmac(
            'sha256',
            provided_password.encode('utf-8'),
            salt,
            100000
        )
        return new_key == stored_key
    except:
        return False

# Декоратор для проверки JWT токена
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]
            except IndexError:
                return jsonify({'message': 'Неверный формат токена'}), 401
        if not token:
            return jsonify({'message': 'Токен отсутствует'}), 401
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user_id = data['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'message': 'Срок действия токена истёк'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'message': 'Недействительный токен'}), 401

        # Загружаем данные пользователя из базы данных
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT * FROM users WHERE user_id = %s', (current_user_id,))
        current_user = cursor.fetchone()
        conn.close()
        if not current_user:
            return jsonify({'message': 'Пользователь не найден'}), 404
        return f(current_user, *args, **kwargs)  # Теперь это словарь
    return decorated

# Регистрация пользователя (обновлено)
@app.route('/api/register', methods=['POST'])
def register():
    data = request.json
    required_fields = ['phone', 'password', 'first_name', 'last_name', 'birth_date', 'user_type']
    if not all(field in data for field in required_fields):
        return jsonify({'message': 'Не все обязательные поля заполнены'}), 400

    # Проверка типа пользователя
    if data['user_type'] not in ['individual', 'business']:
        return jsonify({'message': 'Некорректный тип пользователя'}), 400

    # Для бизнес-аккаунтов обязательна категория
    if data['user_type'] == 'business' and 'business_category' not in data:
        return jsonify({'message': 'Для бизнес-аккаунта укажите категорию'}), 400

    hashed_password = hash_password(data['password'])
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute('SELECT 1 FROM users WHERE phone_number = %s', (data['phone'],))
        if cursor.fetchone():
            return jsonify({'message': 'Пользователь с таким телефоном уже существует'}), 400

        # Добавлены user_type и business_category
        cursor.execute(
            '''INSERT INTO users
            (phone_number, password_hash, first_name, last_name, 
             birth_date, role_id, user_type, business_category)
            VALUES (%s, %s, %s, %s, %s, 1, %s, %s)''',
            (data['phone'], hashed_password, data['first_name'],
             data['last_name'], data['birth_date'], 
             data['user_type'], data.get('business_category'))
        )

        user_id = cursor.lastrowid
        account_number = f'40817810{user_id:010d}'
        
        # Создаем основной счет (тип 1 - Текущий)
        cursor.execute(
            'INSERT INTO accounts (account_number, user_id, type_id, balance) VALUES (%s, %s, 1, 0)',
            (account_number, user_id)
        )
        
        # Для бизнеса создаем дополнительный счет (тип 5 - Основной)
        if data['user_type'] == 'business':
            cursor.execute(
                'INSERT INTO accounts (account_number, user_id, type_id, balance) VALUES (%s, %s, 5, 0)',
                (f'40817820{user_id:010d}', user_id)
            )

        conn.commit()
        return jsonify({'message': 'Регистрация успешна', 'user_id': user_id}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'message': str(e)}), 500
    finally:
        if conn and conn.is_connected():
            conn.close()

# Авторизация пользователя
@app.route('/api/login', methods=['POST'])
def login():
    auth = request.json
    if not auth or 'phone' not in auth or 'password' not in auth:
        return jsonify({'message': 'Необходимо указать телефон и пароль'}), 400
    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT * FROM users WHERE phone_number = %s', (auth['phone'],))
        user = cursor.fetchone()

        if not user:
            return jsonify({'message': 'Пользователь не найден'}), 404
        # Проверка пароля
        if not verify_password(user['password_hash'], auth['password']):
            return jsonify({'message': 'Неверный пароль'}), 401
        # Генерация JWT токена
        token = jwt.encode({
            'user_id': user['user_id'],
            'exp': datetime.utcnow() + timedelta(seconds=JWT_EXP_DELTA_SECONDS)
        }, JWT_SECRET, algorithm=JWT_ALGORITHM)

        return jsonify({
            'token': token,
            'user_id': user['user_id'],
            'first_name': user['first_name'],
            'last_name': user['last_name']
        }), 200
    finally:
        if conn and conn.is_connected():
            conn.close()

@app.route('/api/verify-token', methods=['POST'])
def verify_token():
    token = request.headers.get('Authorization').split()[1]
    try:
        jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        return jsonify({'valid': True}), 200
    except Exception as e:
        return jsonify({'valid': False, 'error': str(e)}), 401

# Получение информации о пользователе (обновлено)
@app.route('/api/user/<int:user_id>', methods=['GET'])
@token_required
def get_user(current_user, user_id):
    if current_user['user_id'] != user_id and current_user['role_id'] != 3:
        return jsonify({'message': 'Unauthorized access!'}), 403

    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('''
            SELECT u.*, r.role_name 
            FROM users u 
            JOIN user_roles r ON u.role_id = r.role_id 
            WHERE u.user_id = %s
        ''', (user_id,))
        user = cursor.fetchone()

        if user:
            user.pop('password_hash', None)
            return jsonify(user), 200
        return jsonify({'message': 'User not found!'}), 404
    finally:
        if conn and conn.is_connected():
            conn.close()

# Обновление информации о пользователе
@app.route('/api/user/<int:user_id>', methods=['PUT'])
@token_required
def update_user(current_user, user_id):
    if current_user['user_id'] != user_id and current_user['role_id'] != 3:
        return jsonify({'message': 'Unauthorized access!'}), 403

    data = request.json
    conn = get_db_connection()
    try:
        cursor = conn.cursor()

        # Обновляем только разрешенные поля
        update_fields = []
        values = []

        if 'first_name' in data:
            update_fields.append('first_name = %s')
            values.append(data['first_name'])

        if 'last_name' in data:
            update_fields.append('last_name = %s')
            values.append(data['last_name'])

        if 'birth_date' in data:
            update_fields.append('birth_date = %s')
            values.append(data['birth_date'])

        if 'user_type' in data and current_user['role_id'] == 3:
            update_fields.append('user_type = %s')
            values.append(data['user_type'])

        if 'business_category' in data and data.get('user_type') == 'business':
            update_fields.append('business_category = %s')
            values.append(data['business_category'])

        if not update_fields:
            return jsonify({'message': 'No fields to update'}), 400

        values.append(user_id)
        query = f'UPDATE users SET {", ".join(update_fields)} WHERE user_id = %s'
        cursor.execute(query, tuple(values))
        conn.commit()

        return jsonify({'message': 'User updated successfully'}), 200
    finally:
        if conn and conn.is_connected():
            conn.close()

# Получение счетов пользователя (обновлено)
@app.route('/api/user/<int:user_id>/accounts', methods=['GET'])
@token_required
def get_user_accounts(current_user, user_id):
    if current_user['user_id'] != user_id and current_user['role_id'] != 3:
        return jsonify({'message': 'Unauthorized access!'}), 403
        
    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('''
            SELECT a.*, at.type_name, at.interest_rate
            FROM accounts a
            JOIN account_types at ON a.type_id = at.type_id
            WHERE a.user_id = %s AND a.is_active = 1
        ''', (user_id,))
        accounts = cursor.fetchall()
        return jsonify(accounts), 200
    finally:
        if conn and conn.is_connected():
            conn.close()

# Создание нового счета (обновлено)
@app.route('/api/user/<int:user_id>/accounts', methods=['POST'])
@token_required
def create_account(current_user, user_id):
    if current_user['user_id'] != user_id:
        return jsonify({'message': 'Unauthorized access!'}), 403

    data = request.json
    if 'type_id' not in data:
        return jsonify({'message': 'Account type is required'}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute('SELECT MAX(account_id) AS max_id FROM accounts')
        max_id = cursor.fetchone()[0] or 0
        account_number = f'40817810{max_id + 1:010d}'

        cursor.execute(
            'INSERT INTO accounts (account_number, user_id, type_id, balance) '
            'VALUES (%s, %s, %s, 0)',
            (account_number, user_id, data['type_id'])
        )

        account_id = cursor.lastrowid
        cursor.execute('''
            SELECT a.*, at.type_name
            FROM accounts a
            JOIN account_types at ON a.type_id = at.type_id
            WHERE a.account_id = %s
        ''', (account_id,))
        new_account = cursor.fetchone()

        conn.commit()
        return jsonify(new_account), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'message': str(e)}), 500
    finally:
        if conn and conn.is_connected():
            conn.close()

# Перевод между счетами (обновлено)
@app.route('/api/transfer', methods=['POST'])
@token_required
def transfer(current_user):
    data = request.json
    from_account_id = data['from_account_id']
    to_account_id = data['to_account_id']
    amount = data['amount']

    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)

        # Проверяем принадлежность счета
        cursor.execute('SELECT user_id FROM accounts WHERE account_id = %s', (from_account_id,))
        account_owner = cursor.fetchone()
        if not account_owner or account_owner['user_id'] != current_user['user_id']:
            return jsonify({'message': 'Invalid account!'}), 400

        # Проверяем достаточность средств
        cursor.execute('SELECT balance FROM accounts WHERE account_id = %s', (from_account_id,))
        balance = cursor.fetchone()['balance']
        if balance < amount:
            return jsonify({'message': 'Insufficient funds!'}), 400

        # Выполняем перевод
        transaction_uuid = str(uuid.uuid4())

        # Списание со счета отправителя
        cursor.execute(
            'UPDATE accounts SET balance = balance - %s WHERE account_id = %s',
            (amount, from_account_id)
        )

        # Зачисление на счет получателя
        cursor.execute(
            'UPDATE accounts SET balance = balance + %s WHERE account_id = %s',
            (amount, to_account_id)
        )

        # Определяем тип получателя для категории
        cursor.execute('''
            SELECT u.user_type, u.business_category 
            FROM users u
            JOIN accounts a ON a.user_id = u.user_id
            WHERE a.account_id = %s
        ''', (to_account_id,))
        recipient_info = cursor.fetchone()
        
        category_id = 7  # По умолчанию "Переводы"
        if recipient_info and recipient_info['user_type'] == 'business':
            cursor.execute('''
                SELECT category_id FROM transaction_categories
                WHERE category_name = %s
            ''', (recipient_info['business_category'],))
            category = cursor.fetchone()
            if category:
                category_id = category['category_id']

        # Записываем транзакцию (добавлены type_id и category_id)
        cursor.execute(
            '''INSERT INTO transactions 
            (transaction_uuid, from_account_id, to_account_id, amount, 
             type_id, category_id) 
            VALUES (%s, %s, %s, %s, 1, %s)''',
            (transaction_uuid, from_account_id, to_account_id, amount, category_id)
        )

        # Начисление бонусов за перевод (0.5% от суммы)
        bonus_amount = amount * 0.005
        if bonus_amount > 0:
            cursor.execute(
                'UPDATE users SET bonus_balance = bonus_balance + %s WHERE user_id = %s',
                (bonus_amount, current_user['user_id'])
            )
            cursor.execute(
                '''INSERT INTO bonus_operations 
                (user_id, amount, operation_type, description) 
                VALUES (%s, %s, 'accrual', 'Бонус за перевод')''',
                (current_user['user_id'], bonus_amount)
            )

        conn.commit()
        return jsonify({'message': 'Transfer successful'}), 200
    except mysql.connector.Error as err:
        conn.rollback()
        return jsonify({'error': str(err)}), 400
    finally:
        if conn and conn.is_connected():
            conn.close()

# Перевод по номеру телефона (P2P)
@app.route('/api/transfer-by-phone', methods=['POST'])
@token_required
def transfer_by_phone(current_user):
    data = request.json
    from_account_id = data['from_account_id']
    recipient_phone = data['recipient_phone']
    amount = data['amount']

    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)

        # Проверяем принадлежность счета
        cursor.execute('''
            SELECT a.account_id FROM accounts a
            JOIN users u ON a.user_id = u.user_id
            WHERE u.phone_number = %s AND a.type_id = 1 AND a.is_active = 1
        ''', (recipient_phone,))
        account_owner = cursor.fetchone()
        if not account_owner or account_owner['user_id'] != current_user['user_id']:
            return jsonify({'message': 'Invalid account!'}), 400

        # Проверяем достаточность средств
        cursor.execute('SELECT balance FROM accounts WHERE account_id = %s', (from_account_id,))
        balance = cursor.fetchone()['balance']
        if balance < amount:
            return jsonify({'message': 'Insufficient funds!'}), 400

        # Находим получателя
        cursor.execute('SELECT user_id, user_type FROM users WHERE phone_number = %s', (recipient_phone,))
        recipient = cursor.fetchone()
        if not recipient:
            return jsonify({'message': 'Recipient not found!'}), 404

        # Находим основной счет получателя
        cursor.execute('''
            SELECT account_id FROM accounts
            WHERE user_id = %s AND type_id = 1 AND is_active = 1
            ORDER BY opening_date ASC
            LIMIT 1
        ''', (recipient['user_id'],))
        to_account = cursor.fetchone()

        if not to_account:
            return jsonify({'message': 'Recipient has no active accounts!'}), 400

        to_account_id = to_account['account_id']

        # Определяем тип операции
        transaction_type = 1  # P2P перевод
        category_id = 7        # Категория "Переводы"

        # Если получатель - юрлицо, то это покупка
        if recipient['user_type'] == 'business':
            transaction_type = 2  # P2B платеж
            # Определяем категорию бизнеса
            cursor.execute('''
                SELECT c.category_id
                FROM transaction_categories c
                WHERE c.category_name = (
                    SELECT business_category FROM users WHERE user_id = %s
                )
            ''', (recipient['user_id'],))
            category = cursor.fetchone()
            category_id = category['category_id'] if category else 10  # Другое

        # Выполняем перевод
        transaction_uuid = str(uuid.uuid4())

        # Списание со счета отправителя
        cursor.execute(
            'UPDATE accounts SET balance = balance - %s WHERE account_id = %s',
            (amount, from_account_id)
        )

        # Зачисление на счет получателя
        cursor.execute(
            'UPDATE accounts SET balance = balance + %s WHERE account_id = %s',
            (amount, to_account_id)
        )

        # Записываем транзакцию
        cursor.execute(
            'INSERT INTO transactions (transaction_uuid, from_account_id, to_account_id, amount, '
            'type_id, recipient_phone, category_id) '
            'VALUES (%s, %s, %s, %s, %s, %s, %s)',
            (transaction_uuid, from_account_id, to_account_id, amount, transaction_type, recipient_phone, category_id)
        )

        # Начисление бонусов (50% от комиссии)
        commission = amount * 0.01  # Предположим, комиссия 1%
        bonus_amount = commission * 0.5

        if bonus_amount > 0:
            # Начисляем бонусы отправителю
            cursor.execute(
                'UPDATE users SET bonus_balance = bonus_balance + %s WHERE user_id = %s',
                (bonus_amount, current_user['user_id'])
            )

            # Записываем операцию с бонусами
            cursor.execute(
                'INSERT INTO bonus_operations (user_id, amount, operation_type, description) '
                'VALUES (%s, %s, "accrual", %s)',
                (current_user['user_id'], bonus_amount, f'Бонус за перевод {recipient_phone}')
            )

        conn.commit()
        return jsonify({'message': 'Transfer successful'}), 200

    except mysql.connector.Error as err:
        conn.rollback()
        return jsonify({'error': str(err)}), 400
    finally:
        if conn and conn.is_connected():
            conn.close()

# Получение истории транзакций (обновлено)
@app.route('/api/user/<int:user_id>/transactions', methods=['GET'])
@token_required
def get_transactions(current_user, user_id):
    if current_user['user_id'] != user_id and current_user['role_id'] != 3:
        return jsonify({'message': 'Unauthorized access!'}), 403

    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('''
            SELECT t.*, tt.type_name, c.category_name,
                   a_from.account_number AS from_account_number,
                   a_to.account_number AS to_account_number
            FROM transactions t
            JOIN transaction_types tt ON t.type_id = tt.type_id
            LEFT JOIN transaction_categories c ON t.category_id = c.category_id
            LEFT JOIN accounts a_from ON t.from_account_id = a_from.account_id
            LEFT JOIN accounts a_to ON t.to_account_id = a_to.account_id
            WHERE t.from_account_id IN (SELECT account_id FROM accounts WHERE user_id = %s)
               OR t.to_account_id IN (SELECT account_id FROM accounts WHERE user_id = %s)
            ORDER BY t.transaction_date DESC
        ''', (user_id, user_id))

        transactions = cursor.fetchall()
        return jsonify(transactions), 200
    finally:
        if conn and conn.is_connected():
            conn.close()


# Получение бонусного баланса (новый метод)
@app.route('/api/user/<int:user_id>/bonuses', methods=['GET'])
@token_required
def get_bonuses(current_user, user_id):
    if current_user['user_id'] != user_id:
        return jsonify({'message': 'Unauthorized access!'}), 403

    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT bonus_balance FROM users WHERE user_id = %s', (user_id,))
        balance = cursor.fetchone()['bonus_balance']

        cursor.execute('''
            SELECT * FROM bonus_operations
            WHERE user_id = %s
            ORDER BY operation_date DESC
        ''', (user_id,))
        operations = cursor.fetchall()

        return jsonify({
            'balance': balance,
            'operations': operations
        }), 200
    finally:
        if conn and conn.is_connected():
            conn.close()

# Покупка авиабилета с бонусами (новый метод)
@app.route('/api/flights/book', methods=['POST'])
@token_required
def book_flight(current_user):
    data = request.json
    ticket_id = data['ticket_id']
    account_id = data['account_id']
    use_bonuses = data.get('use_bonuses', False)

    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Получаем информацию о билете
        cursor.execute('SELECT * FROM air_tickets WHERE ticket_id = %s', (ticket_id,))
        ticket = cursor.fetchone()
        if not ticket or not ticket['is_available']:
            return jsonify({'message': 'Ticket not available!'}), 400
        
        # Проверяем счет
        cursor.execute('SELECT balance FROM accounts WHERE account_id = %s', (account_id,))
        account = cursor.fetchone()
        if not account:
            return jsonify({'message': 'Account not found!'}), 404
            
        # Проверяем бонусный баланс
        cursor.execute('SELECT bonus_balance FROM users WHERE user_id = %s', (current_user['user_id'],))
        bonus_balance = cursor.fetchone()['bonus_balance']
        
        # Рассчитываем оплату
        cash_amount = ticket['price']
        bonus_amount = 0
        
        if use_bonuses:
            max_bonus = min(ticket['price'] * 0.5, bonus_balance)
            bonus_amount = min(max_bonus, bonus_balance)
            cash_amount -= bonus_amount
        
        # Проверяем достаточно ли средств
        if account['balance'] < cash_amount:
            return jsonify({'message': 'Insufficient funds!'}), 400
        
        # Выполняем списания
        transaction_uuid = str(uuid.uuid4())
        
        # Списание денег
        cursor.execute(
            'UPDATE accounts SET balance = balance - %s WHERE account_id = %s',
            (cash_amount, account_id)
        )
        
        # Списание бонусов
        if bonus_amount > 0:
            cursor.execute(
                'UPDATE users SET bonus_balance = bonus_balance - %s WHERE user_id = %s',
                (bonus_amount, current_user['user_id'])
            )
            
            cursor.execute(
                '''INSERT INTO bonus_operations 
                (user_id, amount, operation_type, description) 
                VALUES (%s, %s, 'withdrawal', 'Оплата авиабилета')''',
                (current_user['user_id'], bonus_amount)
            )
        
        # Создаем транзакцию
        cursor.execute(
            '''INSERT INTO transactions 
            (transaction_uuid, from_account_id, amount, type_id, category_id, is_bonus_payment) 
            VALUES (%s, %s, %s, 2, 9, %s)''',
            (transaction_uuid, account_id, cash_amount, 1 if bonus_amount > 0 else 0)
        )
        
        # Помечаем билет как проданный
        cursor.execute(
            'UPDATE air_tickets SET is_available = 0 WHERE ticket_id = %s',
            (ticket_id,)
        )
        
        conn.commit()
        return jsonify({'message': 'Ticket purchased successfully'}), 200
        
    except mysql.connector.Error as err:
        conn.rollback()
        return jsonify({'error': str(err)}), 400
    finally:
        if conn and conn.is_connected():
            conn.close()

# Получение доступных авиабилетов
@app.route('/api/flights', methods=['GET'])
def get_flights():
    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)

        cursor.execute('''
            SELECT * FROM air_tickets
            WHERE is_available = 1 AND departure_time > NOW()
            ORDER BY departure_time ASC
        ''')
        flights = cursor.fetchall()
        return jsonify(flights), 200
    finally:
        if conn and conn.is_connected():
            conn.close()


# Создание тикета в поддержку
@app.route('/api/support/tickets', methods=['POST'])
@token_required
def create_ticket(current_user):
    data = request.json
    subject = data['subject']
    message = data['message']

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO support_tickets (user_id, subject, message_text) '
            'VALUES (%s, %s, %s)',
            (current_user['user_id'], subject, message)
        )
        conn.commit()
        return jsonify({'message': 'Ticket created successfully'}), 201
    finally:
        if conn and conn.is_connected():
            conn.close()

# Получение тикетов пользователя
@app.route('/api/support/tickets', methods=['GET'])
@token_required
def get_user_tickets(current_user):
    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            'SELECT * FROM support_tickets WHERE user_id = %s ORDER BY created_at DESC',
            (current_user['user_id'],)
        )
        tickets = cursor.fetchall()
        return jsonify(tickets), 200
    finally:
        if conn and conn.is_connected():
            conn.close()

# Получение всех тикетов (для поддержки и администратора)
@app.route('/api/support/all-tickets', methods=['GET'])
@token_required
def get_all_tickets(current_user):
    if current_user['role_id'] not in [2, 3]:  # Только поддержка и админ
        return jsonify({'message': 'Unauthorized access!'}), 403

    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('''
            SELECT t.*, u.first_name, u.last_name
            FROM support_tickets t
            JOIN users u ON t.user_id = u.user_id
            ORDER BY t.created_at DESC
        ''')
        tickets = cursor.fetchall()
        return jsonify(tickets), 200
    finally:
        if conn and conn.is_connected():
            conn.close()

# Ответ на тикет
@app.route('/api/support/tickets/<int:ticket_id>/reply', methods=['POST'])
@token_required
def reply_to_ticket(current_user, ticket_id):
    if current_user['role_id'] not in [2, 3]:  # Только поддержка и админ
        return jsonify({'message': 'Unauthorized access!'}), 403

    data = request.json
    reply = data['reply']

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            'UPDATE support_tickets SET reply_text = %s, employee_id = %s, '
            'is_answered = 1, updated_at = NOW() '
            'WHERE ticket_id = %s',
            (reply, current_user['user_id'], ticket_id)
        )
        conn.commit()
        return jsonify({'message': 'Reply sent successfully'}), 200
    finally:
        if conn and conn.is_connected():
            conn.close()

# Получение настроек пользователя
@app.route('/api/user/<int:user_id>/settings', methods=['GET'])
@token_required
def get_settings(current_user, user_id):
    if current_user['user_id'] != user_id:
        return jsonify({'message': 'Unauthorized access!'}), 403

    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT * FROM app_settings WHERE user_id = %s', (user_id,))
        settings = cursor.fetchone()

        if not settings:
            return jsonify({'message': 'Settings not found'}), 404

        return jsonify(settings), 200
    finally:
        if conn and conn.is_connected():
            conn.close()

# Обновление настроек пользователя
@app.route('/api/user/<int:user_id>/settings', methods=['PUT'])
@token_required
def update_settings(current_user, user_id):
    if current_user['user_id'] != user_id:
        return jsonify({'message': 'Unauthorized access!'}), 403

    data = request.json
    conn = get_db_connection()
    try:
        cursor = conn.cursor()

        # Проверяем существование настроек
        cursor.execute('SELECT * FROM app_settings WHERE user_id = %s', (user_id,))
        if not cursor.fetchone():
            # Создаем настройки, если их нет
            cursor.execute(
                'INSERT INTO app_settings (user_id, theme, notifications_enabled) '
                'VALUES (%s, "light", 1)',
                (user_id,)
            )

        # Обновляем настройки
        update_fields = []
        values = []

        if 'theme' in data:
            update_fields.append('theme = %s')
            values.append(data['theme'])

        if 'notifications_enabled' in data:
            update_fields.append('notifications_enabled = %s')
            values.append(1 if data['notifications_enabled'] else 0)

        if 'language' in data:
            update_fields.append('language = %s')
            values.append(data['language'])

        if 'biometrics_enabled' in data:
            update_fields.append('biometrics_enabled = %s')
            values.append(1 if data['biometrics_enabled'] else 0)

        if not update_fields:
            return jsonify({'message': 'No settings to update'}), 400

        values.append(user_id)
        query = f'UPDATE app_settings SET {", ".join(update_fields)} WHERE user_id = %s'
        cursor.execute(query, tuple(values))

        conn.commit()
        return jsonify({'message': 'Settings updated successfully'}), 200
    finally:
        if conn and conn.is_connected():
            conn.close()

# Пополнение счета
@app.route('/api/accounts/<int:account_id>/deposit', methods=['POST'])
@token_required
def deposit(current_user, account_id):
    data = request.json
    amount = data['amount']

    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)

        # Проверяем принадлежность счета
        cursor.execute('SELECT user_id FROM accounts WHERE account_id = %s', (account_id,))
        account = cursor.fetchone()
        if not account or account['user_id'] != current_user['user_id']:
            return jsonify({'message': 'Invalid account!'}), 400

        # Пополняем счет
        cursor.execute(
            'UPDATE accounts SET balance = balance + %s WHERE account_id = %s',
            (amount, account_id)
        )

        # Записываем транзакцию
        transaction_uuid = str(uuid.uuid4())
        cursor.execute(
            'INSERT INTO transactions (transaction_uuid, to_account_id, amount, type_id) '
            'VALUES (%s, %s, %s, 3)',
            (transaction_uuid, account_id, amount)
        )

        conn.commit()
        return jsonify({'message': 'Deposit successful'}), 200
    finally:
        if conn and conn.is_connected():
            conn.close()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
