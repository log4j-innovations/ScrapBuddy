import requests
import base64

API_KEY = "sk_lv0yw89o_t9ka4hdg9HMfP4RsC854EL7O"
url = "https://api.sarvam.ai/text-to-speech"

payload = {
    "text": "पहले कचरे को अलग किया जाना चाहिए.",
    "target_language_code": "hi-IN",
    "speaker": "manisha",  # valid speaker
    "model": "bulbul:v2",
    "output_audio_codec": "wav"
}

headers = {
    "api-subscription-key": API_KEY,
    "Content-Type": "application/json"
}

# Send the POST request
response = requests.post(url, json=payload, headers=headers)
response.raise_for_status()  # raises error if request failed

# Get the base64-encoded audio
base64_audio = response.json()["audios"][0]

# Decode and save it to a .wav file
with open("output.wav", "wb") as f:
    f.write(base64.b64decode(base64_audio))

print("✅ Audio saved as output.wav")
