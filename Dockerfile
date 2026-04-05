# ============================================================
# Image Docker pour l'API FastAPI de prédiction de défaut de crédit
# ============================================================
# Base : Python 3.11 slim (léger mais complet)
FROM python:3.11-slim

# Métadonnées
LABEL maintainer="Projet MLOps DU Data Analytics PS1"
LABEL description="API FastAPI pour la prédiction de défaut de crédit (modèle XGBoost)"

# Variables d'environnement
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Répertoire de travail
WORKDIR /app

# Installation des dépendances système nécessaires à XGBoost
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copie et installation des dépendances Python (en premier pour bénéficier du cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code applicatif et du modèle embarqué (app/model.pkl)
# Le modèle a été préalablement exporté depuis MLflow via export_model.py
COPY app/ ./app/

# Exposition du port FastAPI
EXPOSE 8000

# Vérification de santé du conteneur (health check)
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/')" || exit 1

# Commande de démarrage
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
