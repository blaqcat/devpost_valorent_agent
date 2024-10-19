# Use an official Python runtime as the base image
FROM python:3.9-slim

# ENV AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID
# ENV AWS_SECRET_ACCESS_KEY=WS_SECRET_ACCESS_KEY

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install the required packages
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8501 available to the world outside this container
EXPOSE 8501

# Run the Streamlit app when the container launches
CMD ["streamlit", "run", "main.py"]

