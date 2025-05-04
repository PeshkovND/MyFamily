from flask import Flask, request, jsonify
import httpx
import os

app = Flask(__name__)

API_KEY = os.environ["MISTRALAPITOKEN"]
AGENT_ID = os.environ["MISTRALAGENTID"]

MISTRAL_URL = "https://api.mistral.ai/v1/agents/completions"
TIMEOUT = httpx.Timeout(30.0)

HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

@app.route("/check-text", methods=["POST"])
def check_text():
    data = request.get_json()

    if not data or "text" not in data:
        return jsonify({"error": "Missing 'text' in request body"}), 400

    user_text = data["text"]

    payload = {
        "agent_id": AGENT_ID,
        "messages": [
            {"role": "user", "content": f"Проверь текст: '{user_text}'"}
        ]
    }

    try:
        response = httpx.post(MISTRAL_URL, headers=HEADERS, json=payload, timeout=TIMEOUT)
        response.raise_for_status()
        result = response.json()["choices"][0]["message"]["content"]
        if result not in ["True", "False"]:
            return jsonify({"error": f"Unexpected result"}), 500
        is_toxic = result == "True"
        return jsonify({'data': {'result': is_toxic}})
    except httpx.RequestError as e:
        return jsonify({"error": f"Request error: {str(e)}"}), 500
    except Exception as e:
        return jsonify({"error": f"Unexpected error: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
