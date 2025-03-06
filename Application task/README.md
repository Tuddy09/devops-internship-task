## Steps to Containerize and Automate

### Step 1: Project Setup

Created a directory `calculator-app/` to hold the project files.

### Step 2: Created a Dockerfile

1. Created a `Dockerfile` in the `calculator-app/` directory:
   ```Dockerfile
   FROM python:3.9-slim
   WORKDIR /app
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   RUN pip install flask
   COPY calculator.py .
   ENV FLASK_ENV=production
   ENV PORT=8080
   EXPOSE 8080
   CMD ["gunicorn", "--bind", "0.0.0.0:8080", "calculator:app"]
   ```
   - Uses `python:3.9-slim` as the base image.
   - Installs dependencies, including Flask (added manually).
   - Exposes port 8080 as required.
   - Runs Gunicorn to serve the app.

### Step 3: Local Testing

1. **Built the Docker Image**:
   ```bash
   docker build -t calculator-app:latest .
   ```
2. **Ran the Container**:
   ```bash
   docker run -p 8080:8080 calculator-app:latest
   ```
3. **Tested the Application**:
   - Opened a browser at `http://localhost:8080`.
   - Entered numbers, selected "Add" or "Multiply," and clicked "Calculate."
   - Verified results

### Step 4: Set Up a Docker Registry

1. Created a repository named `calculator-app`
2. Logged in locally:
   ```bash
   docker login
   ```
3. Manually tagged and pushed the image (for testing):
   ```bash
   docker tag calculator-app:latest tuddy09/calculator-app:latest
   docker push tuddy09/calculator-app:latest
   ```

### Step 5: Automation with GitHub Actions

1. **Initialized a Git Repository**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/tuddy09/calculator-app.git
   git branch -M main
   git push -u origin main
   ```
2. **Created a GitHub Actions Workflow**:
   - Added `.github/workflows/docker-build-push.yml`:
     ```yaml
     name: Build and Push Docker Image
     on:
       push:
         branches:
           - main
     jobs:
       build-and-push:
         runs-on: ubuntu-latest
         steps:
           - name: Checkout code
             uses: actions/checkout@v3
           - name: Set up Docker Buildx
             uses: docker/setup-buildx-action@v2
           - name: Log in to Docker Hub
             uses: docker/login-action@v2
             with:
               username: ${{ secrets.DOCKER_USERNAME }}
               password: ${{ secrets.DOCKER_PASSWORD }}
           - name: Get commit hash
             id: vars
             run: echo "COMMIT_HASH=$(git rev-parse --short HEAD)" >> $GITHUB_ENV
           - name: Build and push Docker image
             uses: docker/build-push-action@v4
             with:
               context: .
               push: true
               tags: |
                 tuddy09/calculator-app:latest
                 tuddy09/calculator-app:${{ env.COMMIT_HASH }}
     ```
3. **Added Secrets to GitHub**:
   - Went to GitHub repo > Settings > Secrets and variables > Actions.
   - Added:
     - `DOCKER_USERNAME`
     - `DOCKER_PASSWORD`
4. **Tested the Workflow**:
   - Pushed changes to `main`:
     ```bash
     git add .
     git commit -m "Add GitHub Actions workflow"
     git push
     ```
   - Verified the workflow ran successfully in the "Actions" tab and the image appeared on Docker Hub.

## Running the App

1. Pull the image from Docker Hub:
   ```bash
   docker pull tuddy09/calculator-app:latest
   ```
2. Run the container:
   ```bash
   docker run -p 8080:8080 tuddy09/calculator-app:latest
   ```
3. Access `http://localhost:8080` in a browser.

Also the calculator-app is in github at [https://github.com/Tuddy09/calculator-app.git](https://github.com/Tuddy09/calculator-app.git)
