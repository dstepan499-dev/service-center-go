-- 1. Справочники адресов и банков
CREATE TABLE IF NOT EXISTS cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS streets (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS banks (
    id SERIAL PRIMARY KEY,
    bik VARCHAR(9) UNIQUE NOT NULL,
    name VARCHAR(150) UNIQUE NOT NULL
);

-- 2. Справочники техники
CREATE TABLE IF NOT EXISTS item_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS manufacturers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) UNIQUE NOT NULL,
    country VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    manufacturer_id INT NOT NULL REFERENCES manufacturers(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 3. Справочники дефектов и кадровой структуры
CREATE TABLE IF NOT EXISTS faults (
    id SERIAL PRIMARY KEY,
    description VARCHAR(255) UNIQUE NOT NULL,
    repair_hours INT NOT NULL CHECK (repair_hours > 0),
    fixed_cost DECIMAL(10,2) NOT NULL CHECK (fixed_cost >= 0)
);

CREATE TABLE IF NOT EXISTS specializations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS qualifications (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS positions (
    id SERIAL PRIMARY KEY,
    okpdtr_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(150) UNIQUE NOT NULL
);

-- 4. Клиенты (физлица и юрлица)
CREATE TABLE IF NOT EXISTS individuals (
    id SERIAL PRIMARY KEY,
    surname VARCHAR(100) NOT NULL CHECK (length(trim(surname)) > 0),
    first_name VARCHAR(100) NOT NULL CHECK (length(trim(first_name)) > 0),
    patronymic VARCHAR(100),
    house_number VARCHAR(15) NOT NULL,
    apartment_number VARCHAR(15),
    phone VARCHAR(20) UNIQUE NOT NULL,
    street_id INT NOT NULL REFERENCES streets(id) ON UPDATE CASCADE,
    city_id INT NOT NULL REFERENCES cities(id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS legal_entities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) UNIQUE NOT NULL CHECK (length(trim(name)) > 0),
    ok_code VARCHAR(20) NOT NULL,
    abbreviation VARCHAR(10) NOT NULL,
    house_number VARCHAR(15) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    head_surname VARCHAR(100) NOT NULL,
    head_first_name VARCHAR(100) NOT NULL,
    head_patronymic VARCHAR(100),
    inn VARCHAR(12) UNIQUE NOT NULL CHECK (inn ~ '^\d{10}$' OR inn ~ '^\d{12}$'),
    payment_account VARCHAR(20) UNIQUE NOT NULL CHECK (payment_account ~ '^\d{20}$'),
    corr_account VARCHAR(20) NOT NULL,
    bank_id INT NOT NULL REFERENCES banks(id) ON UPDATE CASCADE,
    street_id INT NOT NULL REFERENCES streets(id) ON UPDATE CASCADE,
    city_id INT NOT NULL REFERENCES cities(id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS discount_cards (
    id SERIAL PRIMARY KEY,
    card_number VARCHAR(20) UNIQUE NOT NULL,
    discount_percent DECIMAL(5,2) NOT NULL CHECK (discount_percent BETWEEN 0 AND 100),
    client_type VARCHAR(10) NOT NULL CHECK (client_type IN ('individual', 'legal')),
    client_id INT NOT NULL
);

-- 5. Персонал
DO $$ BEGIN
    CREATE TYPE emp_status AS ENUM ('active', 'dismissed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    surname VARCHAR(100) NOT NULL CHECK (length(trim(surname)) > 0),
    first_name VARCHAR(100) NOT NULL CHECK (length(trim(first_name)) > 0),
    patronymic VARCHAR(100),
    gender VARCHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
    date_of_birth DATE NOT NULL,
    house_number VARCHAR(15) NOT NULL,
    apartment_number VARCHAR(15),
    phone VARCHAR(20) UNIQUE NOT NULL,
    total_experience INT NOT NULL CHECK (total_experience >= 0),
    daily_order_limit INT NOT NULL CHECK (daily_order_limit > 0),
    status emp_status DEFAULT 'active',
    position_id INT NOT NULL REFERENCES positions(id) ON UPDATE CASCADE,
    department_id INT NOT NULL REFERENCES departments(id) ON UPDATE CASCADE,
    qualification_id INT NOT NULL REFERENCES qualifications(id) ON UPDATE CASCADE,
    specialization_id INT NOT NULL REFERENCES specializations(id) ON UPDATE CASCADE,
    street_id INT NOT NULL REFERENCES streets(id) ON UPDATE CASCADE,
    city_id INT NOT NULL REFERENCES cities(id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS employment_records (
    id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(id) ON UPDATE CASCADE ON DELETE CASCADE,
    event_type VARCHAR(20) NOT NULL CHECK (event_type IN ('hire', 'transfer', 'dismiss')),
    event_date DATE NOT NULL,
    doc_number VARCHAR(50) NOT NULL,
    doc_type VARCHAR(100) NOT NULL,
    termination_reason VARCHAR(255)
);

-- 6. Поставщики и складской запас
CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) UNIQUE NOT NULL,
    ok_code VARCHAR(20) NOT NULL,
    abbreviation VARCHAR(10) NOT NULL,
    house_number VARCHAR(15) NOT NULL,
    sales_phone VARCHAR(20) NOT NULL,
    head_surname VARCHAR(100) NOT NULL,
    head_first_name VARCHAR(100) NOT NULL,
    head_patronymic VARCHAR(100),
    inn VARCHAR(12) UNIQUE NOT NULL CHECK (inn ~ '^\d{10}$' OR inn ~ '^\d{12}$'),
    payment_account VARCHAR(20) UNIQUE NOT NULL CHECK (payment_account ~ '^\d{20}$'),
    corr_account VARCHAR(20) NOT NULL,
    bank_id INT NOT NULL REFERENCES banks(id) ON UPDATE CASCADE,
    street_id INT NOT NULL REFERENCES streets(id) ON UPDATE CASCADE,
    city_id INT NOT NULL REFERENCES cities(id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS spare_parts (
    id SERIAL PRIMARY KEY,
    article VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL CHECK (length(trim(name)) > 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    purchase_price DECIMAL(10,2) NOT NULL CHECK (purchase_price >= 0),
    retail_price DECIMAL(10,2) NOT NULL CHECK (retail_price >= 0),
    supplier_id INT NOT NULL REFERENCES suppliers(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 7. Изделия и заказы
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    item_type_id INT NOT NULL REFERENCES item_types(id) ON UPDATE CASCADE,
    brand_id INT NOT NULL REFERENCES brands(id) ON UPDATE CASCADE,
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    operation_months INT NOT NULL CHECK (operation_months >= 0),
    photo_path VARCHAR(255)
);

DO $$ BEGIN
    CREATE TYPE order_status AS ENUM ('diagnostics', 'repair', 'ready', 'issued');
    CREATE TYPE quality_mark AS ENUM ('success', 'warranty_defect');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(30) UNIQUE NOT NULL,
    item_id INT NOT NULL REFERENCES items(id) ON UPDATE CASCADE,
    client_type VARCHAR(10) NOT NULL CHECK (client_type IN ('individual', 'legal')),
    client_id INT NOT NULL,
    master_id INT NOT NULL REFERENCES employees(id) ON UPDATE CASCADE,
    acceptance_date DATE NOT NULL,
    issue_date DATE,
    warranty_months INT NOT NULL CHECK (warranty_months > 0),
    total_cost DECIMAL(12,2) NOT NULL CHECK (total_cost >= 0),
    status order_status DEFAULT 'diagnostics',
    quality quality_mark DEFAULT 'success',
    CONSTRAINT chk_order_dates CHECK (issue_date IS NULL OR issue_date >= acceptance_date)
);

CREATE TABLE IF NOT EXISTS order_faults (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    fault_id INT NOT NULL REFERENCES faults(id) ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS order_parts (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id) ON UPDATE CASCADE ON DELETE CASCADE,
    part_id INT NOT NULL REFERENCES spare_parts(id) ON UPDATE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0)
);

-- 8. Таблица пользователей приложения (Аутентификация и роли)
CREATE TABLE IF NOT EXISTS app_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(64) NOT NULL, -- SHA-256 (64 hex-символа)
    role VARCHAR(30) NOT NULL CHECK (role IN ('director', 'manager', 'master', 'warehouse', 'admin')),
    full_name VARCHAR(150) NOT NULL,
    employee_id INT REFERENCES employees(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Индексы из ЛР5
CREATE INDEX IF NOT EXISTS idx_orders_date_cost ON orders (acceptance_date DESC, total_cost ASC);
CREATE INDEX IF NOT EXISTS idx_orders_master_id ON orders (master_id);

-- 10. Триггер списания запчастей из ЛР4
CREATE OR REPLACE FUNCTION trigger_write_off_parts()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'issued' AND (OLD.status IS NULL OR OLD.status <> 'issued') THEN
        UPDATE spare_parts p
        SET stock_quantity = p.stock_quantity - op.quantity
        FROM order_parts op
        WHERE op.order_id = NEW.id AND op.part_id = p.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_write_off_parts ON orders;
CREATE TRIGGER trg_write_off_parts
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION trigger_write_off_parts();