import requests

def get_integrated_free_models():
    url = "https://openrouter.ai/api/v1/models"
    
    # শক্তিশালী মডেল এবং ভিশন মডেলের কি-ওয়ার্ড
    top_tier_keywords = ['llama-3.3', 'gemma-4', 'qwen3', 'mistral', 'phi-3', 'hermes']
    vision_keywords = ['vision', 'vl', 'llava', 'multimodal', 'ocr', 'clip']

    try:
        response = requests.get(url)
        if response.status_code == 200:
            models = response.json()['data']
            best_models = []
            other_models = []

            for model in models:
                pricing = model.get('pricing', {})
                # ফ্রি মডেল চেক
                is_free = float(pricing.get('prompt', 1)) == 0 and float(pricing.get('completion', 1)) == 0
                
                if is_free:
                    m_id = model.get('id', '')
                    desc = model.get('description', '').lower()
                    arch = str(model.get('architecture', {})).lower()
                    
                    # মোডালিটি নির্ধারণ (Text vs Vision)
                    is_vision = any(k in m_id.lower() for k in vision_keywords) or \
                                any(k in desc for k in vision_keywords) or \
                                'vision' in arch
                    
                    modality = "📸 Vision+Text" if is_vision else "📝 Text Only"
                    
                    model_data = {
                        'id': m_id,
                        'context': model.get('context_length', 'N/A'),
                        'modality': modality
                    }
                    
                    # প্রায়োরিটি চেক (সেরা মডেলগুলো আগে রাখার জন্য)
                    if any(keyword in m_id.lower() for keyword in top_tier_keywords):
                        best_models.append(model_data)
                    else:
                        other_models.append(model_data)

            return best_models + other_models
        else:
            return f"Error: {response.status_code}"
    except Exception as e:
        return f"An error occurred: {e}"

# ফলাফল সুন্দরভাবে প্রদর্শন করা
print("\n" + "="*85)
print(f"{'No.':<4} {'Model ID':<52} {'Context':<12} {'Capability':<15}")
print("="*85)

integrated_list = get_integrated_free_models()

if isinstance(integrated_list, list):
    for i, model in enumerate(integrated_list, 1):
        # আইডি লম্বা হলে ছোট করে দেখানো
        display_id = (model['id'][:49] + '..') if len(model['id']) > 49 else model['id']
        
        print(f"{i:<4} {display_id:<52} {model['context']:<12} {model['modality']:<15}")
    
    print("="*85)
    print(f"মোট {len(integrated_list)}টি ফ্রি মডেল পাওয়া গেছে।")
else:
    print(integrated_list)