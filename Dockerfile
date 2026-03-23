# Image de base Python légère
FROM python:3.11-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier le fichier des dépendances
COPY backend/requirements.txt .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier tout le projet (pour accéder aux modèles et à la logique)
COPY . .

# Exposer le port FastAPI
EXPOSE 8000

# Commande de lancement (on utilise le mode module pour les imports relatifs)
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
