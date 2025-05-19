 -- Script de inicialización de tablas para el módulo de Finanzas

-- Cuentas bancarias
CREATE TABLE finance.bank_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    account_number VARCHAR(50) NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(50) NOT NULL CHECK (account_type IN ('checking', 'savings', 'credit')),
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    initial_balance DECIMAL(19, 4) NOT NULL DEFAULT 0,
    current_balance DECIMAL(19, 4) NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    accounting_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, account_number, bank_name)
);

-- Tipos de transacciones financieras
CREATE TABLE finance.transaction_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    affects_cash BOOLEAN DEFAULT TRUE,
    direction VARCHAR(10) NOT NULL CHECK (direction IN ('inflow', 'outflow', 'transfer')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Transacciones financieras
CREATE TABLE finance.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    transaction_type_id UUID REFERENCES finance.transaction_types(id),
    bank_account_id UUID REFERENCES finance.bank_accounts(id),
    destination_account_id UUID REFERENCES finance.bank_accounts(id),
    transaction_date DATE NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    reference VARCHAR(100),
    description TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'cancelled', 'reconciled')),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Categorías de flujo de caja
CREATE TABLE finance.cash_flow_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('operating', 'investing', 'financing')),
    is_inflow BOOLEAN NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Relación entre transacciones y categorías de flujo de caja
CREATE TABLE finance.transaction_cash_flow_categories (
    transaction_id UUID REFERENCES finance.transactions(id) ON DELETE CASCADE,
    category_id UUID REFERENCES finance.cash_flow_categories(id) ON DELETE CASCADE,
    amount DECIMAL(19, 4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (transaction_id, category_id)
);

-- Presupuestos
CREATE TABLE finance.budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'approved', 'active', 'closed')),
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, name),
    CHECK (start_date <= end_date)
);

-- Líneas de presupuesto
CREATE TABLE finance.budget_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    budget_id UUID REFERENCES finance.budgets(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounting.chart_of_accounts(id),
    cost_center_id UUID REFERENCES accounting.cost_centers(id),
    period_month INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    period_year INTEGER NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(budget_id, account_id, cost_center_id, period_month, period_year)
);

-- Activos fijos
CREATE TABLE finance.fixed_assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    acquisition_date DATE NOT NULL,
    acquisition_cost DECIMAL(19, 4) NOT NULL,
    residual_value DECIMAL(19, 4) NOT NULL DEFAULT 0,
    useful_life_years INTEGER NOT NULL,
    depreciation_method VARCHAR(20) NOT NULL CHECK (depreciation_method IN ('straight_line', 'declining_balance', 'units_of_production')),
    asset_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    depreciation_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    expense_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'disposed', 'fully_depreciated')),
    disposal_date DATE,
    disposal_amount DECIMAL(19, 4),
    location VARCHAR(100),
    responsible_person VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Depreciación de activos fijos
CREATE TABLE finance.asset_depreciation (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID REFERENCES finance.fixed_assets(id) ON DELETE CASCADE,
    period_month INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    period_year INTEGER NOT NULL,
    depreciation_amount DECIMAL(19, 4) NOT NULL,
    accumulated_depreciation DECIMAL(19, 4) NOT NULL,
    remaining_value DECIMAL(19, 4) NOT NULL,
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(asset_id, period_month, period_year)
);

-- Préstamos y financiamiento
CREATE TABLE finance.loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    lender VARCHAR(100) NOT NULL,
    loan_type VARCHAR(50) NOT NULL CHECK (loan_type IN ('term_loan', 'line_of_credit', 'mortgage', 'leasing')),
    principal_amount DECIMAL(19, 4) NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL,
    interest_type VARCHAR(20) NOT NULL CHECK (interest_type IN ('fixed', 'variable')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    payment_frequency VARCHAR(20) NOT NULL CHECK (payment_frequency IN ('monthly', 'quarterly', 'semi_annual', 'annual')),
    number_of_payments INTEGER NOT NULL,
    liability_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    interest_expense_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    bank_account_id UUID REFERENCES finance.bank_accounts(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'paid', 'defaulted', 'restructured')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Pagos de préstamos
CREATE TABLE finance.loan_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID REFERENCES finance.loans(id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,
    payment_number INTEGER NOT NULL,
    principal_amount DECIMAL(19, 4) NOT NULL,
    interest_amount DECIMAL(19, 4) NOT NULL,
    total_amount DECIMAL(19, 4) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('scheduled', 'paid', 'partial', 'late', 'defaulted')),
    transaction_id UUID REFERENCES finance.transactions(id),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(loan_id, payment_number)
);

-- Inversiones
CREATE TABLE finance.investments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    investment_type VARCHAR(50) NOT NULL CHECK (investment_type IN ('fixed_deposit', 'bonds', 'stocks', 'mutual_funds', 'real_estate')),
    amount DECIMAL(19, 4) NOT NULL,
    expected_return_rate DECIMAL(5, 2),
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'matured', 'sold', 'cancelled')),
    asset_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    income_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    bank_account_id UUID REFERENCES finance.bank_accounts(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Retornos de inversiones
CREATE TABLE finance.investment_returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    investment_id UUID REFERENCES finance.investments(id) ON DELETE CASCADE,
    return_date DATE NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    description TEXT,
    transaction_id UUID REFERENCES finance.transactions(id),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Análisis financiero - Ratios
CREATE TABLE finance.financial_ratios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    period_month INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    period_year INTEGER NOT NULL,
    current_ratio DECIMAL(10, 4),
    quick_ratio DECIMAL(10, 4),
    debt_to_equity DECIMAL(10, 4),
    debt_to_assets DECIMAL(10, 4),
    interest_coverage DECIMAL(10, 4),
    gross_profit_margin DECIMAL(10, 4),
    operating_profit_margin DECIMAL(10, 4),
    net_profit_margin DECIMAL(10, 4),
    return_on_assets DECIMAL(10, 4),
    return_on_equity DECIMAL(10, 4),
    inventory_turnover DECIMAL(10, 4),
    receivables_turnover DECIMAL(10, 4),
    payables_turnover DECIMAL(10, 4),
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, period_month, period_year)
);

-- Gestión de riesgos financieros
CREATE TABLE finance.risk_assessments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    risk_type VARCHAR(50) NOT NULL CHECK (risk_type IN ('credit', 'liquidity', 'market', 'operational', 'compliance')),
    description TEXT NOT NULL,
    impact_level VARCHAR(20) NOT NULL CHECK (impact_level IN ('low', 'medium', 'high', 'critical')),
    probability VARCHAR(20) NOT NULL CHECK (probability IN ('unlikely', 'possible', 'likely', 'almost_certain')),
    mitigation_strategy TEXT,
    responsible_user_id UUID REFERENCES core.users(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('identified', 'assessed', 'mitigated', 'monitored', 'closed')),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Conciliación bancaria
CREATE TABLE finance.bank_reconciliations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    bank_account_id UUID REFERENCES finance.bank_accounts(id),
    period_month INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    period_year INTEGER NOT NULL,
    statement_balance DECIMAL(19, 4) NOT NULL,
    book_balance DECIMAL(19, 4) NOT NULL,
    reconciled_balance DECIMAL(19, 4) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'in_progress', 'completed')),
    completed_by UUID REFERENCES core.users(id),
    completed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, bank_account_id, period_month, period_year)
);

-- Elementos de conciliación bancaria
CREATE TABLE finance.reconciliation_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reconciliation_id UUID REFERENCES finance.bank_reconciliations(id) ON DELETE CASCADE,
    transaction_id UUID REFERENCES finance.transactions(id),
    item_type VARCHAR(50) NOT NULL CHECK (item_type IN ('outstanding_check', 'deposit_in_transit', 'bank_fee', 'interest_earned', 'error_correction', 'other')),
    amount DECIMAL(19, 4) NOT NULL,
    description TEXT,
    is_cleared BOOLEAN DEFAULT FALSE,
    cleared_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos iniciales

-- Tipos de transacciones financieras
INSERT INTO finance.transaction_types (company_id, code, name, affects_cash, direction)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'DEP', 'Depósito', TRUE, 'inflow'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'WIT', 'Retiro', TRUE, 'outflow'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'TRF', 'Transferencia', TRUE, 'transfer'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PAY', 'Pago a Proveedor', TRUE, 'outflow'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'REC', 'Cobro a Cliente', TRUE, 'inflow'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SAL', 'Pago de Nómina', TRUE, 'outflow'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'TAX', 'Pago de Impuestos', TRUE, 'outflow'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'INT', 'Intereses Ganados', TRUE, 'inflow'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'FEE', 'Comisiones Bancarias', TRUE, 'outflow');

-- Categorías de flujo de caja
INSERT INTO finance.cash_flow_categories (company_id, code, name, type, is_inflow)
VALUES 
    -- Operativas
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SAL', 'Ventas', 'operating', TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'COGS', 'Costo de Ventas', 'operating', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SALA', 'Salarios', 'operating', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RENT', 'Alquiler', 'operating', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'UTIL', 'Servicios Públicos', 'operating', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'TAX', 'Impuestos', 'operating', FALSE),
    
    -- Inversión
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CAPEX', 'Compra de Activos', 'investing', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ASALE', 'Venta de Activos', 'investing', TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'INVST', 'Inversiones', 'investing', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'INVRT', 'Retorno de Inversiones', 'investing', TRUE),
    
    -- Financiamiento
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'LOAN', 'Préstamos Recibidos', 'financing', TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'LOANP', 'Pago de Préstamos', 'financing', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'DIVID', 'Dividendos Pagados', 'financing', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'EQTY', 'Aportes de Capital', 'financing', TRUE);

-- Cuentas bancarias
INSERT INTO finance.bank_accounts (company_id, account_number, bank_name, account_type, currency, initial_balance, current_balance)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '1234567890', 'Banco Nacional', 'checking', 'COP', 10000000, 10000000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '0987654321', 'Banco Internacional', 'savings', 'COP', 5000000, 5000000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), '1122334455', 'Banco Comercial', 'credit', 'COP', 0, 0);

