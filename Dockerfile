# Start with a small Python image
FROM python:latest

# Set the folder inside the container where the project will live
WORKDIR /app

# Copy the list of required tools to the container
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all project files into the container
COPY . .

# Tell Docker to use port 8000
EXPOSE 8000

# Command to start Django when the container runs
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

