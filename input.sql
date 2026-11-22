DROP DATABASE IF EXISTS pm07_v07;
CREATE DATABASE pm07_v07;
\c pm07_v07

DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'pm07_admin') THEN
      CREATE ROLE pm07_admin LOGIN PASSWORD '<SECRET_REMOVED>';
   END IF;
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'pm07_app_user') THEN
      CREATE ROLE pm07_app_user LOGIN PASSWORD '<SECRET_REMOVED>';
   END IF;
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'pm07_readonly') THEN
      CREATE ROLE pm07_readonly LOGIN PASSWORD '<SECRET_REMOVED>';
   END IF;
END
$$;

CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL DEFAULT 0
);

CREATE TABLE masters (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(80) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL DEFAULT 0
);

CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(id),
    master_id INT REFERENCES masters(id),
    service_name VARCHAR(100) NOT NULL,
    visit_date TIMESTAMP NOT NULL,
    amount NUMERIC(10, 2) NOT NULL
);

CREATE TABLE access_probe (
    id SERIAL PRIMARY KEY,
    checked_by VARCHAR(50),
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO clients (full_name, phone, amount) VALUES
('Иванова Анна Сергеевна', '+79991112233', 1500.00),
('Петрова Мария Олеговна', '+79992223344', 500.00),
('Смирнова Елена Викторовна', '+79993334455', 3000.00);

INSERT INTO masters (full_name, specialization, amount) VALUES
('Козлова Дарья', 'Стилист-колорист', 45000.00),
('Морозова Ксения', 'Мастер маникюра', 38000.00),
('Волкова Алина', 'Косметолог', 52000.00);

INSERT INTO appointments (client_id, master_id, service_name, visit_date, amount) VALUES
(1, 1, 'Сложное окрашивание AirTouch', '2026-11-10 10:00:00', 8500.00),
(2, 2, 'Комбинированный маникюр с покрытием', '2026-11-11 14:30:00', 2500.00),
(3, 3, 'Уходовая чистка лица', '2026-11-12 16:00:00', 4200.00),
(1, 2, 'Педикюр аппаратный', '2026-11-14 11:00:00', 3100.00);

INSERT INTO access_probe (checked_by) VALUES ('init_setup');

GRANT ALL PRIVILEGES ON DATABASE pm07_v07 TO pm07_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pm07_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO pm07_admin;

GRANT CONNECT ON DATABASE pm07_v07 TO pm07_app_user;
GRANT USAGE ON SCHEMA public TO pm07_app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO pm07_app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO pm07_app_user;

GRANT CONNECT ON DATABASE pm07_v07 TO pm07_readonly;
GRANT USAGE ON SCHEMA public TO pm07_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO pm07_readonly;
