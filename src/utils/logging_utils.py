import logging
import os


def setup_logger(name):
    # Configura o root logger (que a Lambda já usa para o CloudWatch)
    root_logger = logging.getLogger()
    
    log_level = os.getenv("LOG_LEVEL", "INFO").upper()
    root_logger.setLevel(log_level)

    # Só adiciona handler se ainda não tiver (evita duplicados entre invocações)
    if not root_logger.handlers:
        handler = logging.StreamHandler()
        handler.setLevel(log_level)
        formatter = logging.Formatter(
            "%(asctime)s | %(levelname)s | %(name)s | %(message)s"
        )
        handler.setFormatter(formatter)
        root_logger.addHandler(handler)

    # Devolve logger com o nome do módulo (para aparecer nos logs)
    return logging.getLogger(name)