# Use a slim Python 3.11 image for performance and security
FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Copy dependency file first to leverage Docker cache
COPY backend/requirements.txt .

# Install dependencies without storing cache to keep image small
RUN pip install --no-cache-dir -r requirements.txt

# Copy only the backend application code (Isolation)
# This prevents mobile/3D source code from being included in the API image.
COPY backend/app ./app

# Expose the FastAPI port
EXPOSE 8000

# Launch the application using the module path
# uvicorn app.main:app allows for relative imports within the app package.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
