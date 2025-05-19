 -- Script de inicialización de tablas para el módulo de Contabilidad

-- Plan de cuentas
CREATE TABLE accounting.chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    account_type VARCHAR(50) NOT NULL CHECK (account_type IN ('asset', 'liability', 'equity', 'revenue', 'expense')),
    parent_id UUID REFERENCES accounting.chart_of_accounts(id),
    level INTEGER NOT NULL,
    path LTREE,
    is_group BOOLEAN DEFAULT FALSE,
    balance_type VARCHAR(10) NOT NULL CHECK (balance_type IN ('debit', 'credit')),
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Índice para búsquedas jerárquicas
CREATE INDEX chart_of_accounts_path_idx ON accounting.chart_of_accounts USING GIST (path);

-- Clasificación de cuentas para balance general
CREATE TABLE accounting.balance_sheet_classifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    section VARCHAR(50) NOT NULL CHECK (section IN ('current_assets', 'non_current_assets', 'current_liabilities', 'non_current_liabilities', 'equity')),
    display_order INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Clasificación de cuentas para estado de resultados
CREATE TABLE accounting.income_statement_classifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    section VARCHAR(50) NOT NULL CHECK (section IN ('operating_revenue', 'operating_expense', 'non_operating_revenue', 'non_operating_expense', 'tax')),
    display_order INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Relación entre cuentas y clasificaciones de balance
CREATE TABLE accounting.account_balance_classifications (
    account_id UUID REFERENCES accounting.chart_of_accounts(id) ON DELETE CASCADE,
    classification_id UUID REFERENCES accounting.balance_sheet_classifications(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (account_id, classification_id)
);

-- Relación entre cuentas y clasificaciones de estado de resultados
CREATE TABLE accounting.account_income_classifications (
    account_id UUID REFERENCES accounting.chart_of_accounts(id) ON DELETE CASCADE,
    classification_id UUID REFERENCES accounting.income_statement_classifications(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (account_id, classification_id)
);

-- Períodos fiscales
CREATE TABLE accounting.fiscal_periods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed BOOLEAN DEFAULT FALSE,
    closed_at TIMESTAMP WITH TIME ZONE,
    closed_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, name),
    CHECK (start_date <= end_date)
);

-- Centros de costos
CREATE TABLE accounting.cost_centers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES accounting.cost_centers(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Tipos de documentos contables
CREATE TABLE accounting.document_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Asientos contables
CREATE TABLE accounting.journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    fiscal_period_id UUID REFERENCES accounting.fiscal_periods(id),
    document_type_id UUID REFERENCES accounting.document_types(id),
    document_number VARCHAR(50),
    date DATE NOT NULL,
    reference VARCHAR(100),
    description TEXT,
    is_posted BOOLEAN DEFAULT FALSE,
    is_reversed BOOLEAN DEFAULT FALSE,
    reversed_by UUID REFERENCES accounting.journal_entries(id),
    posted_at TIMESTAMP WITH TIME ZONE,
    posted_by UUID REFERENCES core.users(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Líneas de asientos contables
CREATE TABLE accounting.journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounting.chart_of_accounts(id),
    description TEXT,
    debit DECIMAL(19, 4) DEFAULT 0,
    credit DECIMAL(19, 4) DEFAULT 0,
    cost_center_id UUID REFERENCES accounting.cost_centers(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (debit >= 0 AND credit >= 0),
    CHECK (debit = 0 OR credit = 0)
);

-- Tasas de impuestos
CREATE TABLE accounting.tax_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    rate DECIMAL(5, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    account_id UUID REFERENCES accounting.chart_of_accounts(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Actividades ICA (Impuesto de Industria y Comercio)
CREATE TABLE accounting.ica_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    rate DECIMAL(5, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    account_id UUID REFERENCES accounting.chart_of_accounts(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Retenciones en la fuente
CREATE TABLE accounting.withholding_taxes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    rate DECIMAL(5, 2) NOT NULL,
    min_amount DECIMAL(19, 4),
    account_id UUID REFERENCES accounting.chart_of_accounts(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Revelaciones para estados financieros
CREATE TABLE accounting.financial_statement_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    fiscal_period_id UUID REFERENCES accounting.fiscal_periods(id),
    note_number INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, fiscal_period_id, note_number)
);

-- Saldos de cuentas
CREATE TABLE accounting.account_balances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounting.chart_of_accounts(id),
    fiscal_period_id UUID REFERENCES accounting.fiscal_periods(id),
    period_month INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    period_year INTEGER NOT NULL,
    opening_debit DECIMAL(19, 4) DEFAULT 0,
    opening_credit DECIMAL(19, 4) DEFAULT 0,
    period_debit DECIMAL(19, 4) DEFAULT 0,
    period_credit DECIMAL(19, 4) DEFAULT 0,
    closing_debit DECIMAL(19, 4) DEFAULT 0,
    closing_credit DECIMAL(19, 4) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, account_id, fiscal_period_id, period_month, period_year)
);

-- Plantillas de asientos contables
CREATE TABLE accounting.journal_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, name)
);

-- Líneas de plantillas de asientos
CREATE TABLE accounting.journal_template_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id UUID REFERENCES accounting.journal_templates(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounting.chart_of_accounts(id),
    description TEXT,
    is_debit BOOLEAN NOT NULL,
    percentage DECIMAL(5, 2),
    amount DECIMAL(19, 4),
    cost_center_id UUID REFERENCES accounting.cost_centers(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos iniciales

-- Tipos de documentos contables
INSERT INTO accounting.document_types (company_id, code, name, description)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'JE', 'Asiento Manual', 'Asiento contable manual'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SI', 'Factura de Venta', 'Asiento generado por factura de venta'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PI', 'Factura de Compra', 'Asiento generado por factura de compra'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PR', 'Recibo de Pago', 'Asiento generado por recibo de pago'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SR', 'Recibo de Cobro', 'Asiento generado por recibo de cobro'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ADJ', 'Ajuste', 'Asiento de ajuste contable');

-- Tasas de impuestos
INSERT INTO accounting.tax_rates (company_id, code, name, rate)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'IVA19', 'IVA 19%', 19.00),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'IVA5', 'IVA 5%', 5.00),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'IVA0', 'IVA 0%', 0.00);

-- Retenciones en la fuente
INSERT INTO accounting.withholding_taxes (company_id, code, name, rate, min_amount)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RFTE4', 'Retención en la Fuente 4%', 4.00, 1000000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RFTE6', 'Retención en la Fuente 6%', 6.00, 800000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RFTE11', 'Retención en la Fuente 11%', 11.00, 800000);

-- Actividades ICA
INSERT INTO accounting.ica_activities (company_id, code, name, rate)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ICA001', 'Comercio al por mayor', 8.00),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ICA002', 'Comercio al por menor', 10.00),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ICA003', 'Servicios', 10.00);

-- Clasificaciones de balance general
INSERT INTO accounting.balance_sheet_classifications (company_id, code, name, section, display_order)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CA', 'Activos Corrientes', 'current_assets', 1),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'NCA', 'Activos No Corrientes', 'non_current_assets', 2),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CL', 'Pasivos Corrientes', 'current_liabilities', 3),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'NCL', 'Pasivos No Corrientes', 'non_current_liabilities', 4),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'EQ', 'Patrimonio', 'equity', 5);

-- Clasificaciones de estado de resultados
INSERT INTO accounting.income_statement_classifications (company_id, code, name, section, display_order)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'OR', 'Ingresos Operacionales', 'operating_revenue', 1),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'OE', 'Gastos Operacionales', 'operating_expense', 2),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'NOR', 'Ingresos No Operacionales', 'non_operating_revenue', 3),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'NOE', 'Gastos No Operacionales', 'non_operating_expense', 4),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'TAX', 'Impuestos', 'tax', 5);

-- Centros de costos
INSERT INTO accounting.cost_centers (company_id, code, name, parent_id)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ADM', 'Administración', NULL),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'VEN', 'Ventas', NULL),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PRO', 'Producción', NULL),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'FIN', 'Finanzas', NULL);

-- Período fiscal
INSERT INTO accounting.fiscal_periods (company_id, name, start_date, end_date)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Año Fiscal 2025', '2025-01-01', '2025-12-31');

-- Plan de cuentas básico
INSERT INTO accounting.chart_of_accounts (company_id, code, name, account_type, level, is_group, balance_type, path)
VALUES 
    -- Nivel 1
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '1', 'ACTIVOS', 'asset', 1, TRUE, 'debit', '1'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '2', 'PASIVOS', 'liability', 1, TRUE, 'credit', '2'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '3', 'PATRIMONIO', 'equity', 1, TRUE, 'credit', '3'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '4', 'INGRESOS', 'revenue', 1, TRUE, 'credit', '4'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '5', 'GASTOS', 'expense', 1, TRUE, 'debit', '5'),
    
    -- Nivel 2 - Activos
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '11', 'EFECTIVO Y EQUIVALENTES', 'asset', 2, TRUE, 'debit', '1.11'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '13', 'DEUDORES', 'asset', 2, TRUE, 'debit', '1.13'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '15', 'INVENTARIOS', 'asset', 2, TRUE, 'debit', '1.15'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '17', 'ACTIVOS FIJOS', 'asset', 2, TRUE, 'debit', '1.17'),
    
    -- Nivel 2 - Pasivos
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '21', 'OBLIGACIONES FINANCIERAS', 'liability', 2, TRUE, 'credit', '2.21'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '22', 'PROVEEDORES', 'liability', 2, TRUE, 'credit', '2.22'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '23', 'CUENTAS POR PAGAR', 'liability', 2, TRUE, 'credit', '2.23'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '24', 'IMPUESTOS', 'liability', 2, TRUE, 'credit', '2.24'),
    
    -- Nivel 2 - Patrimonio
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '31', 'CAPITAL SOCIAL', 'equity', 2, TRUE, 'credit', '3.31'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '36', 'RESULTADOS DEL EJERCICIO', 'equity', 2, TRUE, 'credit', '3.36'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '37', 'RESULTADOS DE EJERCICIOS ANTERIORES', 'equity', 2, TRUE, 'credit', '3.37'),
    
    -- Nivel 2 - Ingresos
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '41', 'OPERACIONALES', 'revenue', 2, TRUE, 'credit', '4.41'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '42', 'NO OPERACIONALES', 'revenue', 2, TRUE, 'credit', '4.42'),
    
    -- Nivel 2 - Gastos
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '51', 'OPERACIONALES DE ADMINISTRACIÓN', 'expense', 2, TRUE, 'debit', '5.51'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '52', 'OPERACIONALES DE VENTAS', 'expense', 2, TRUE, 'debit', '5.52'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '53', 'NO OPERACIONALES', 'expense', 2, TRUE, 'debit', '5.53');

-- Actualizar parent_id para las cuentas de nivel 2
UPDATE accounting.chart_of_accounts SET parent_id = (SELECT id FROM accounting.chart_of_accounts WHERE code = '1') WHERE code LIKE '1%' AND level = 2;
UPDATE accounting.chart_of_accounts SET parent_id = (SELECT id FROM accounting.chart_of_accounts WHERE code = '2') WHERE code LIKE '2%' AND level = 2;
UPDATE accounting.chart_of_accounts SET parent_id = (SELECT id FROM accounting.chart_of_accounts WHERE code = '3') WHERE code LIKE '3%' AND level = 2;
UPDATE accounting.chart_of_accounts SET parent_id = (SELECT id FROM accounting.chart_of_accounts WHERE code = '4') WHERE code LIKE '4%' AND level = 2;
UPDATE accounting.chart_of_accounts SET parent_id = (SELECT id FROM accounting.chart_of_accounts WHERE code = '5') WHERE code LIKE '5%' AND level = 2;

-- Nivel 3 - Algunas cuentas específicas
INSERT INTO accounting.chart_of_accounts (company_id, code, name, account_type, parent_id, level, is_group, balance_type, path)
VALUES 
    -- Efectivo y equivalentes
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '1105', 'CAJA', 'asset', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '11'), 3, FALSE, 'debit', '1.11.1105'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '1110', 'BANCOS', 'asset', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '11'), 3, FALSE, 'debit', '1.11.1110'),
    
    -- Deudores
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '1305', 'CLIENTES', 'asset', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '13'), 3, FALSE, 'debit', '1.13.1305'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '1355', 'ANTICIPOS Y AVANCES', 'asset', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '13'), 3, FALSE, 'debit', '1.13.1355'),
    
    -- Inventarios
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '1505', 'MATERIAS PRIMAS', 'asset', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '15'), 3, FALSE, 'debit', '1.15.1505'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '1520', 'PRODUCTOS TERMINADOS', 'asset', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '15'), 3, FALSE, 'debit', '1.15.1520'),
    
    -- Proveedores
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '2205', 'PROVEEDORES NACIONALES', 'liability', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '22'), 3, FALSE, 'credit', '2.22.2205'),
    
    -- Impuestos
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '2408', 'IVA POR PAGAR', 'liability', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '24'), 3, FALSE, 'credit', '2.24.2408'),
    
    -- Ingresos operacionales
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '4135', 'COMERCIO AL POR MAYOR Y MENOR', 'revenue', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '41'), 3, FALSE, 'credit', '4.41.4135'),
    
    -- Gastos operacionales
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '5105', 'GASTOS DE PERSONAL', 'expense', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '51'), 3, FALSE, 'debit', '5.51.5105'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '5110', 'HONORARIOS', 'expense', 
     (SELECT id FROM accounting.chart_of_accounts WHERE code = '51'), 3, FALSE, 'debit', '5.51.5110');

-- Asignar clasificaciones de balance general
INSERT INTO accounting.account_balance_classifications (account_id, classification_id)
VALUES
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '11'), 
     (SELECT id FROM accounting.balance_sheet_classifications WHERE code = 'CA')),
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '13'), 
     (SELECT id FROM accounting.balance_sheet_classifications WHERE code = 'CA')),
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '15'), 
     (SELECT id FROM accounting.balance_sheet_classifications WHERE code = 'CA')),
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '17'), 
     (SELECT id FROM accounting.balance_sheet_classifications WHERE code = 'NCA')),
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '21'), 
     (SELECT id FROM accounting.balance_sheet_classifications WHERE code = 'CL')),
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '22'), 
     (SELECT id FROM accounting.balance_sheet_classifications WHERE code = 'CL')),
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '31'), 
     (SELECT id FROM accounting.balance_sheet_classifications WHERE code = 'EQ'));

-- Asignar clasificaciones de estado de resultados
INSERT INTO accounting.account_income_classifications (account_id, classification_id)
VALUES
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '41'), 
     (SELECT id FROM accounting.income_statement_classifications WHERE code = 'OR')),
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '42'), 
     (SELECT id FROM accounting.income_statement_classifications WHERE code = 'NOR')),
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '51'), 
     (SELECT id FROM accounting.income_statement_classifications WHERE code = 'OE')),
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '52'), 
     (SELECT id FROM accounting.income_statement_classifications WHERE code = 'OE')),
    ((SELECT id FROM accounting.chart_of_accounts WHERE code = '53'), 
     (SELECT id FROM accounting.income_statement_classifications WHERE code = 'NOE'));

