import requests

def get_free_models():
    url = "https://openrouter.ai/api/v1/models"
    response = requests.get(url)
    if response.status_code == 200:
        models = response.json()['data']
        free_models = []
        for model in models:
            # চেক করা হচ্ছে ইনপুট এবং আউটপুট দুটোর দামই ০ কি না
            if float(model['pricing']['prompt']) == 0 and float(model['pricing']['completion']) == 0:
                free_models.append(model['id'])
        return free_models
    else:
        return "Error fetching models"

print("বর্তমান ফ্রি মডেলগুলো হলো:")
print(get_free_models())