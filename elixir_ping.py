import requests
import sys

BASE_URL = "https://api.prod.elixir.xyz/validators/"

def check_server_status(address):
    """Перевіряє статус сервера для конкретної адреси."""
    url = f"{BASE_URL}{address}"
    try:
        # Надсилаємо запит до сервера
        response = requests.get(url, timeout=10)
        
        # Перевіряємо статус відповіді
        if response.status_code == 200:
            data = response.json()
            
            # Дістаємо статус 'online'
            online_status = data.get("validator", {}).get("online", False)
            
            # Повертаємо результат
            return (address, online_status)
        else:
            print(f"⚠️ Помилка запиту для {address}: {response.status_code}")
            return (address, None)
    except requests.exceptions.RequestException as e:
        print(f"❌ Помилка підключення для {address}: {e}")
        return (address, None)

def main(validator_addresses):
    """Основна функція для перевірки кількох серверів."""
    print("Перевірка серверів:")
    results = []
    for address in validator_addresses:
        status = check_server_status(address)
        results.append(status)

    # Виведення результатів
    print("\nРезультати перевірки:")
    for address, status in results:
        if status is True:
            print(f"✅ {address} активний.")
        elif status is False:
            print(f"❌ {address} неактивний.")
        else:
            print(f"⚠️ {address} невідома помилка або відсутність відповіді.")

if __name__ == "__main__":
    # Читаємо вхідні параметри
    if len(sys.argv) > 1:
        # Отримуємо адреси, розділені комою
        input_addresses = sys.argv[1].split(",")
    else:
        print("❌ Не передано жодної адреси. Використання: python script.py <address1,address2,...>")
        sys.exit(1)

    main(input_addresses)