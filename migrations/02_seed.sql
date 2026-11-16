-- 1. Города, улицы и банки
INSERT INTO cities (name) VALUES 
('Новосибирск'), ('Бердск'), ('Искитим'), ('Обь')
ON CONFLICT (name) DO NOTHING;

INSERT INTO streets (name) VALUES 
('пр. Карла Маркса'), ('ул. Немировича-Данченко'), ('ул. Ленина'), ('ул. Блюхера'), ('ул. Геодезическая')
ON CONFLICT (name) DO NOTHING;

INSERT INTO banks (bik, name) VALUES 
('045004641', 'Сибирский банк ПАО Сбербанк'),
('045004774', 'Филиал ПАО Банк ВТБ г. Новосибирск'),
('045004885', 'АО Альфа-Банк Новосибирск')
ON CONFLICT (bik) DO NOTHING;

-- 2. Справочники техники
INSERT INTO item_types (name) VALUES 
('Телевизор'), ('Стиральная машина'), ('Микроволновая печь'), 
('Холодильник'), ('Пылесос'), ('Кофемашина')
ON CONFLICT (name) DO NOTHING;

INSERT INTO manufacturers (name, country) VALUES 
('Samsung Electronics', 'Южная Корея'),
('LG Electronics', 'Южная Корея'),
('Robert Bosch GmbH', 'Германия'),
('Philips Electronics', 'Нидерланды'),
('Indesit Company', 'Италия')
ON CONFLICT (name) DO NOTHING;

INSERT INTO brands (name, manufacturer_id) VALUES 
('Samsung', 1), ('LG', 2), ('Bosch', 3), ('Philips', 4), ('Indesit', 5)
ON CONFLICT (name) DO NOTHING;

-- 3. Неисправности (с нормами времени и базовой стоимостью)
INSERT INTO faults (description, repair_hours, fixed_cost) VALUES 
('Замена блока питания / инвертора', 2, 1800.00),
('Восстановление системной платы (пайка)', 4, 3200.00),
('Замена магнетрона СВЧ', 2, 1500.00),
('Замена подшипников барабана', 5, 4500.00),
('Замена компрессора хладагента', 6, 5000.00),
('Чистка гидросистемы и замена уплотнителей', 3, 2200.00),
('Замена помпы слива', 2, 1600.00)
ON CONFLICT (description) DO NOTHING;

-- 4. Кадровая структура (должности по ОКПДТР 2025)
INSERT INTO positions (okpdtr_code, name) VALUES 
('20434', 'Директор сервисного центра'),
('24042', 'Менеджер по приему заказов'),
('16340', 'Мастер по ремонту электробытовой техники'),
('21345', 'Заведующий складом'),
('20311', 'Бухгалтер')
ON CONFLICT (okpdtr_code) DO NOTHING;

INSERT INTO departments (name) VALUES 
('Дирекция'), ('Отдел приемки и клиентского сервиса'), 
('Участок ремонта крупной техники'), ('Участок ремонта мелкой техники'), 
('Склад комплектующих')
ON CONFLICT (name) DO NOTHING;

INSERT INTO specializations (name) VALUES 
('Теле- и видеоаппаратура'), ('Крупная бытовая техника'), 
('Мелкая кухонная техника'), ('Климатическое оборудование')
ON CONFLICT (name) DO NOTHING;

INSERT INTO qualifications (name) VALUES 
('3 разряд'), ('4 разряд'), ('5 разряд'), ('Мастер высшей категории')
ON CONFLICT (name) DO NOTHING;

-- 5. Сотрудники
INSERT INTO employees (surname, first_name, patronymic, gender, date_of_birth, house_number, apartment_number, phone, total_experience, daily_order_limit, status, position_id, department_id, qualification_id, specialization_id, street_id, city_id) VALUES 
('Дружин', 'Степан', 'Вадимович', 'M', '1985-04-12', '20', '15', '+79130010001', 12, 10, 'active', 1, 1, 4, 1, 1, 1),
('Смирнова', 'Елена', 'Игоревна', 'F', '1994-08-23', '35', '42', '+79130010002', 5, 20, 'active', 2, 2, 2, 3, 2, 1),
('Иванов', 'Сергей', 'Петрович', 'M', '1989-11-05', '14', '7', '+79130010003', 8, 4, 'active', 3, 3, 3, 2, 3, 1),
('Ковалев', 'Алексей', 'Николаевич', 'M', '1992-02-17', '8', '110', '+79130010004', 6, 5, 'active', 3, 4, 3, 3, 4, 1),
('Сидоров', 'Виктор', 'Михайлович', 'M', '1980-06-30', '52', NULL, '+79130010005', 15, 15, 'active', 4, 5, 4, 1, 5, 1)
ON CONFLICT (phone) DO NOTHING;

-- 6. Записи в трудовой книжке (кадровый учет)
INSERT INTO employment_records (employee_id, event_type, event_date, doc_number, doc_type, termination_reason) VALUES 
(1, 'hire', '2018-02-01', 'ПР-01/18', 'Приказ о приеме на работу', NULL),
(2, 'hire', '2021-04-15', 'ПР-14/21', 'Приказ о приеме на работу', NULL),
(3, 'hire', '2019-09-01', 'ПР-45/19', 'Приказ о приеме на работу', NULL),
(4, 'hire', '2020-03-10', 'ПР-12/20', 'Приказ о приеме на работу', NULL),
(5, 'hire', '2016-11-20', 'ПР-88/16', 'Приказ о приеме на работу', NULL);

-- 7. Поставщики и запчасти
INSERT INTO suppliers (name, ok_code, abbreviation, house_number, sales_phone, head_surname, head_first_name, head_patronymic, inn, payment_account, corr_account, bank_id, street_id, city_id) VALUES 
('ООО "СибЭлектроСнаб"', '45.31.1', 'ООО', '101', '+73832001122', 'Семенов', 'Олег', 'Павлович', '5405123456', '40702810900000001234', '30101810145250000974', 1, 1, 1),
('АО "ТехноИмпорт"', '46.43.1', 'АО', '50/2', '+73833334455', 'Григорьев', 'Роман', 'Сергеевич', '5406987654', '40702810100000005678', '30101810145250000974', 2, 2, 1)
ON CONFLICT (inn) DO NOTHING;

INSERT INTO spare_parts (article, name, stock_quantity, purchase_price, retail_price, supplier_id) VALUES 
('SP-SNG-001', 'Магнетрон 2M214 Samsung', 14, 1200.00, 2100.00, 1),
('SP-LGE-002', 'Плата управления LG Inverter', 6, 2400.00, 4200.00, 2),
('SP-BSH-003', 'Комплект подшипников и сальник Bosch', 20, 850.00, 1600.00, 1),
('SP-PHL-004', 'Помпа сливная Askoll универсальная', 18, 600.00, 1150.00, 1),
('SP-CMP-005', 'Компрессор Jiaxipera R600a', 5, 3100.00, 5600.00, 2)
ON CONFLICT (article) DO NOTHING;

-- 8. Клиенты и дисконтные карты
INSERT INTO individuals (surname, first_name, patronymic, house_number, apartment_number, phone, street_id, city_id) VALUES 
('Петров', 'Андрей', 'Васильевич', '12', '34', '+79231112233', 1, 1),
('Кузнецова', 'Анна', 'Сергеевна', '45', '12', '+79234445566', 3, 1),
('Морозов', 'Дмитрий', 'Александрович', '7', '89', '+79237778899', 4, 2)
ON CONFLICT (phone) DO NOTHING;

INSERT INTO legal_entities (name, ok_code, abbreviation, house_number, phone, head_surname, head_first_name, head_patronymic, inn, payment_account, corr_account, bank_id, street_id, city_id) VALUES 
('ООО "Гостиница Центральная"', '55.10', 'ООО', '1', '+73832220033', 'Васильев', 'Игорь', 'Михайлович', '5407112233', '40702810500000009999', '30101810145250000974', 1, 3, 1)
ON CONFLICT (inn) DO NOTHING;

INSERT INTO discount_cards (card_number, discount_percent, client_type, client_id) VALUES 
('CARD-1001', 5.00, 'individual', 1),
('CARD-1002', 10.00, 'individual', 2),
('CARD-2001', 15.00, 'legal', 1)
ON CONFLICT (card_number) DO NOTHING;

-- 9. Изделия и заказы
INSERT INTO items (item_type_id, brand_id, serial_number, operation_months, photo_path) VALUES 
(1, 1, 'SN-SMG-TV-2023-01', 14, '/photos/tv_samsung.jpg'),
(2, 3, 'SN-BSH-WM-2022-88', 28, '/photos/wm_bosch.jpg'),
(3, 2, 'SN-LGE-MW-2024-55', 6, '/photos/mw_lg.jpg')
ON CONFLICT (serial_number) DO NOTHING;

INSERT INTO orders (order_number, item_id, client_type, client_id, master_id, acceptance_date, issue_date, warranty_months, total_cost, status, quality) VALUES 
('ORD-2026-001', 1, 'individual', 1, 3, '2026-10-15', '2026-10-18', 6, 5300.00, 'issued', 'success'),
('ORD-2026-002', 2, 'legal', 1, 3, '2026-11-01', '2026-11-05', 12, 6100.00, 'issued', 'success'),
('ORD-2026-003', 3, 'individual', 2, 4, CURRENT_DATE, NULL, 6, 3600.00, 'repair', 'success')
ON CONFLICT (order_number) DO NOTHING;

INSERT INTO order_faults (order_id, fault_id) VALUES 
(1, 2), (2, 4), (3, 3)
ON CONFLICT DO NOTHING;

INSERT INTO order_parts (order_id, part_id, quantity) VALUES 
(1, 2, 1), (2, 3, 1), (3, 1, 1)
ON CONFLICT DO NOTHING;

-- 10. Пользователи системы (Пароли: director123, manager123, master123, wh123, admin123)
-- Хеши сформированы через sha256
INSERT INTO app_users (username, password_hash, role, full_name, employee_id) VALUES 
('director', encode(sha256('director123'::bytea), 'hex'), 'director', 'Дружин Степан Вадимович', 1),
('manager', encode(sha256('manager123'::bytea), 'hex'), 'manager', 'Смирнова Елена Игоревна', 2),
('master', encode(sha256('master123'::bytea), 'hex'), 'master', 'Иванов Сергей Петрович', 3),
('warehouse', encode(sha256('wh123'::bytea), 'hex'), 'warehouse', 'Сидоров Виктор Михайлович', 5),
('admin', encode(sha256('admin123'::bytea), 'hex'), 'admin', 'Администратор Системы', NULL)
ON CONFLICT (username) DO NOTHING;