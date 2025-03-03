from flask import Flask, request, jsonify
from transformers import pipeline

# Инициализация Flask приложения
app = Flask(__name__)

# Загрузка модели для классификации токсичности
toxicity_classifier = pipeline(
    "text-classification",
    model="unitary/multilingual-toxic-xlm-roberta"
)

# Маршрут для обработки POST запросов
@app.route('/check_toxicity', methods=['POST'])
def check_toxicity():
    # Получаем текст из запроса
    data = request.json
    text = data.get('text', '')

    if not text:
        return jsonify({'error': 'Text is required'}), 400

    # Классификация текста
    result = toxicity_classifier(text)

    # Возвращаем результат
    return jsonify({'data': {'result': result}})

# Запуск сервера
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
