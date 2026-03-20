import logging
import os


def setup_logger(name):
    logger = logging.getLogger(name)
    if not logger.hasHandlers():
        log_level = os.getenv("LOG_LEVEL", "INFO").upper()
        logger.setLevel(log_level)

        handler = logging.StreamHandler()
        handler.setLevel(log_level)
        formatter = logging.Formatter(
                    "%(asctime)s | %(levelname)s | %(name)s | %(message)s"
                )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    return logger
