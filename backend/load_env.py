from dotenv import load_dotenv
import os

load_dotenv()

print("Private Key:", os.getenv("PRIVATE_KEY")[:6] + "...")  # Masked
