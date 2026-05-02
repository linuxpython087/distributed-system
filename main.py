from fastapi import FastAPI
import requests
import time
import logging

app = FastAPI()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(name)s - %(message)s"
)

logger = logging.getLogger(__name__)

API_URL = "https://jsonplaceholder.typicode.com/posts/1"


def fetch_data_with_fault_tolerance():
    max_retries = 3
    timeout = 2  # seconds

    for attempt in range(1, max_retries + 1):
        try:
            logger.info(f"Attempt {attempt}...")

            response = requests.get(API_URL, timeout=timeout)
            response.raise_for_status()

            logger.info("Request successful")

            return {
                "status": "success",
                "data": response.json()
            }

        except requests.exceptions.Timeout:
            logger.warning("⏱ Timeout occurred")

        except requests.exceptions.ConnectionError:
            logger.error("🔌 Connection error")

        except requests.exceptions.HTTPError as e:
            logger.error(f"❌ HTTP error: {e}")

        time.sleep(attempt)

    logger.error("All retries failed. Using fallback.")

    return fallback_response()


def fallback_response():
    logger.info("Returning fallback response")
    return {
        "status": "fallback",
        "data": {
            "message": "Service unavailable, using fallback",
            "cached": False
        }
    }


@app.get("/")
def home():
    return fetch_data_with_fault_tolerance()