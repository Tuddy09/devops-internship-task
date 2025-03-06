#!/bin/bash

# Stop and remove any existing container
docker stop postgres-container 2>/dev/null || true
docker rm postgres-container 2>/dev/null || true

# Start a new container
echo "Starting container..."
docker run --name postgres-container -e POSTGRES_PASSWORD=mysecretpassword -d -p 5432:5432 -v ~/postgres-data:/var/lib/postgresql/data postgres || { echo "Failed to start container"; exit 1; }

# Wait for initialization
sleep 5

# Create database
echo "Creating database..."
docker exec postgres-container psql -U postgres -c "CREATE DATABASE company_db;" || { echo "Failed to create database"; exit 1; }

# Create user "tremend"
echo "Creating user tremend..."
docker exec postgres-container psql -U postgres -c "CREATE USER tremend WITH PASSWORD 'tremendpassword';" || { echo "Failed to create tremend"; exit 1; }
docker exec postgres-container psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE company_db TO tremend;" || { echo "Failed to grant privileges to tremend"; exit 1; }
docker exec postgres-container psql -U postgres -d company_db -c "GRANT CREATE, USAGE ON SCHEMA public TO tremend;" || { echo "Failed to grant schema privileges to tremend"; exit 1; }

# Create user "ps_cee"
echo "Creating user ps_cee..."
docker exec postgres-container psql -U postgres -c "CREATE USER ps_cee WITH PASSWORD 'ps_ceepassword';" || { echo "Failed to create ps_cee"; exit 1; }
docker exec postgres-container psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE company_db TO ps_cee;" || { echo "Failed to grant privileges to ps_cee"; exit 1; }
docker exec postgres-container psql -U postgres -d company_db -c "GRANT CREATE, USAGE ON SCHEMA public TO ps_cee;" || { echo "Failed to grant schema privileges to ps_cee"; exit 1; }

# Import dataset
echo "Importing dataset..."
DATASET_PATH="$(pwd)/populatedb.sql"
docker cp "$DATASET_PATH" postgres-container:/dataset.sql || { echo "Failed to copy dataset.sql"; exit 1; }
docker exec postgres-container psql -U tremend -d company_db -f /../dataset.sql || { echo "Failed to import dataset"; exit 1; }

# Verify import
echo "Verifying data import..."
docker exec postgres-container psql -U tremend -d company_db -c "SELECT COUNT(*) FROM employees;" || { echo "Failed to verify employees"; exit 1; }

# Run queries and log results
echo "Running queries..."

# Clear previous log
> query_results.log

# Query 1
echo "Total number of employees:" >> query_results.log
docker exec postgres-container psql -U tremend -d company_db -c "SELECT COUNT(*) AS total_employees FROM employees;" >> query_results.log 2>&1 || echo "Query 1 failed" >> query_results.log

# Get department input outside redirection
echo "Enter a department (e.g., Sales, IT, HR):"
read -p "Department: " dept
if [ -z "$dept" ]; then
    echo "No input provided, defaulting to 'Sales'"
    dept="Sales"
fi

# Query 2
echo "Names of employees in '$dept':" >> query_results.log
docker exec postgres-container psql -U tremend -d company_db -c "SELECT e.first_name, e.last_name FROM employees e JOIN departments d ON e.department_id = d.department_id WHERE d.department_name = '$dept';" >> query_results.log 2>&1 || echo "Query 2 failed" >> query_results.log

# Query 3
echo "Highest and lowest salaries per department:" >> query_results.log
docker exec postgres-container psql -U tremend -d company_db -c "SELECT d.department_name, MAX(s.salary) AS highest_salary, MIN(s.salary) AS lowest_salary FROM departments d LEFT JOIN employees e ON d.department_id = e.department_id LEFT JOIN salaries s ON e.employee_id = s.employee_id GROUP BY d.department_name;" >> query_results.log 2>&1 || echo "Query 3 failed" >> query_results.log

# Dump database
echo "Dumping database..."
docker exec postgres-container pg_dump -U tremend -d company_db > company_db_dump.sql || { echo "Failed to dump database"; exit 1; }

echo "Script completed."