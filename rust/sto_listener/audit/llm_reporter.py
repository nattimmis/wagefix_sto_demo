import openai

def audit_event(event):
    return openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": f"Audit this event: {event}"}]
    )
