## Files
- `setup_db.sh`: Bash script to automate the setup and queries.
- `query_results.log`: Output of the SQL queries.
- `company_db_dump.sql`: Database dump file.

## Steps Taken
1. **Pulled PostgreSQL Image:**
   - Command: `docker pull postgres:latest`

2. **Ran the Container:**
   - Command: `docker run --name postgres-container -e POSTGRES_PASSWORD=mysecretpassword -d -p 5432:5432 -v ~/postgres-data:/var/lib/postgresql/data postgres`
   - Started a container named `postgres-container` with a password, detached mode, port mapping, and a persistent volume at `~/postgres-data`.

3. **Created Database:**
   - Command: `docker exec postgres-container psql -U postgres -c "CREATE DATABASE company_db;"`
   - Created a database named `company_db` using the `postgres` user.

4. **Created User "tremend":**
   - Commands:
     - `docker exec postgres-container psql -U postgres -c "CREATE USER tremend WITH PASSWORD 'tremendpassword';"`
     - `docker exec postgres-container psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE company_db TO tremend;"`
     - `docker exec postgres-container psql -U postgres -d company_db -c "GRANT CREATE, USAGE ON SCHEMA public TO tremend;"`
   - Created user `tremend`, granted database privileges, and allowed schema creation in `public`.

5. **Created User "ps_cee":**
   - Commands:
     - `docker exec postgres-container psql -U postgres -c "CREATE USER ps_cee WITH PASSWORD 'ps_ceepassword';"`
     - `docker exec postgres-container psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE company_db TO ps_cee;"`
     - `docker exec postgres-container psql -U postgres -d company_db -c "GRANT CREATE, USAGE ON SCHEMA public TO ps_cee;"`
   - Created a second admin user `ps_cee` with similar privileges.

6. **Imported Dataset:**
   - Commands:
     - `DATASET_PATH="$(pwd)/populatedb.sql"`
     - `docker cp "$DATASET_PATH" postgres-container:/dataset.sql`
     - `docker exec postgres-container psql -U tremend -d company_db -f /dataset.sql`
   - Explanation: Defined the dataset path, copied `populatedb.sql` to the container, and imported it into `company_db` with 53 employees.
   - Also there was an error in the populatedb.sql, there were more salaries than employees and there was a foreign key error when trying to assign a salary to a non-existent ID, solved it by removing some salaries from the file

7. **Ran Queries:**
   - Commands (in script):
     - `docker exec postgres-container psql -U tremend -d company_db -c "SELECT COUNT(*) AS total_employees FROM employees;"`
     - `read -p "Department: " dept`
     - `docker exec postgres-container psql -U tremend -d company_db -c "SELECT e.first_name, e.last_name FROM employees e JOIN departments d ON e.department_id = d.department_id WHERE d.department_name = '$dept';"`
     - `docker exec postgres-container psql -U tremend -d company_db -c "SELECT d.department_name, MAX(s.salary) AS highest_salary, MIN(s.salary) AS lowest_salary FROM departments d LEFT JOIN employees e ON d.department_id = e.department_id LEFT JOIN salaries s ON e.employee_id = s.employee_id GROUP BY d.department_name;"`
   - Queried total employees, prompted for a department (`Sales`), listed employees in that department, and calculated max/min salaries per department, logging to `query_results.log`.

8. **Dumped Database:**
   - Command: `docker exec postgres-container pg_dump -U tremend -d company_db > company_db_dump.sql`
   - Exported the full database to `company_db_dump.sql`.

9. **Automated with Script:**
   - Command: `chmod +x setup_db.sh && ./setup_db.sh`
   - Made the script executable and ran it to perform all steps in one go.
