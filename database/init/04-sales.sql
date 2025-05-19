-- Script de inicialización de tablas para el módulo de Ventas

-- Clientes
CREATE TABLE sales.customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    tax_id VARCHAR(20),
    customer_type VARCHAR(20) NOT NULL CHECK (customer_type IN ('individual', 'company', 'government')),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    credit_limit DECIMAL(19, 4),
    payment_term_days INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Contactos de clientes
CREATE TABLE sales.customer_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES sales.customers(id) ON DELETE CASCADE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    is_primary BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Categorías de clientes
CREATE TABLE sales.customer_categories (
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

-- Relación entre clientes y categorías
CREATE TABLE sales.customer_category_assignments (
    customer_id UUID REFERENCES sales.customers(id) ON DELETE CASCADE,
    category_id UUID REFERENCES sales.customer_categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id, category_id)
);

-- Listas de precios
CREATE TABLE sales.price_lists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Precios de productos
CREATE TABLE sales.product_prices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    price_list_id UUID REFERENCES sales.price_lists(id) ON DELETE CASCADE,
    product_id UUID REFERENCES inventory.products(id) ON DELETE CASCADE,
    price DECIMAL(19, 4) NOT NULL,
    min_quantity INTEGER DEFAULT 1,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(price_list_id, product_id, min_quantity)
);

-- Asignación de listas de precios a clientes
CREATE TABLE sales.customer_price_lists (
    customer_id UUID REFERENCES sales.customers(id) ON DELETE CASCADE,
    price_list_id UUID REFERENCES sales.price_lists(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id, price_list_id)
);

-- Descuentos
CREATE TABLE sales.discounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount')),
    value DECIMAL(19, 4) NOT NULL,
    start_date DATE,
    end_date DATE,
    min_quantity INTEGER,
    min_amount DECIMAL(19, 4),
    is_cumulative BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Asignación de descuentos a productos
CREATE TABLE sales.product_discounts (
    discount_id UUID REFERENCES sales.discounts(id) ON DELETE CASCADE,
    product_id UUID REFERENCES inventory.products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (discount_id, product_id)
);

-- Asignación de descuentos a categorías de productos
CREATE TABLE sales.product_category_discounts (
    discount_id UUID REFERENCES sales.discounts(id) ON DELETE CASCADE,
    category_id UUID REFERENCES inventory.product_categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (discount_id, category_id)
);

-- Asignación de descuentos a clientes
CREATE TABLE sales.customer_discounts (
    discount_id UUID REFERENCES sales.discounts(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES sales.customers(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (discount_id, customer_id)
);

-- Asignación de descuentos a categorías de clientes
CREATE TABLE sales.customer_category_discounts (
    discount_id UUID REFERENCES sales.discounts(id) ON DELETE CASCADE,
    category_id UUID REFERENCES sales.customer_categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (discount_id, category_id)
);

-- Vendedores
CREATE TABLE sales.salespeople (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    user_id UUID REFERENCES core.users(id),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    commission_rate DECIMAL(5, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Zonas de venta
CREATE TABLE sales.sales_zones (
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

-- Asignación de vendedores a zonas
CREATE TABLE sales.salesperson_zones (
    salesperson_id UUID REFERENCES sales.salespeople(id) ON DELETE CASCADE,
    zone_id UUID REFERENCES sales.sales_zones(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (salesperson_id, zone_id)
);

-- Asignación de clientes a zonas
CREATE TABLE sales.customer_zones (
    customer_id UUID REFERENCES sales.customers(id) ON DELETE CASCADE,
    zone_id UUID REFERENCES sales.sales_zones(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id, zone_id)
);

-- Cotizaciones/Presupuestos
CREATE TABLE sales.quotes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    quote_number VARCHAR(20) NOT NULL,
    customer_id UUID REFERENCES sales.customers(id),
    contact_id UUID REFERENCES sales.customer_contacts(id),
    salesperson_id UUID REFERENCES sales.salespeople(id),
    quote_date DATE NOT NULL,
    valid_until DATE NOT NULL,
    price_list_id UUID REFERENCES sales.price_lists(id),
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    exchange_rate DECIMAL(10, 4) DEFAULT 1,
    subtotal DECIMAL(19, 4) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    total DECIMAL(19, 4) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'sent', 'approved', 'rejected', 'expired', 'converted')),
    notes TEXT,
    terms_conditions TEXT,
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, quote_number)
);

-- Líneas de cotización
CREATE TABLE sales.quote_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quote_id UUID REFERENCES sales.quotes(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    unit_price DECIMAL(19, 4) NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0,
    discount_amount DECIMAL(19, 4) DEFAULT 0,
    tax_percentage DECIMAL(5, 2) DEFAULT 0,
    tax_amount DECIMAL(19, 4) DEFAULT 0,
    subtotal DECIMAL(19, 4) NOT NULL,
    total DECIMAL(19, 4) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(quote_id, line_number)
);

-- Pedidos de venta
CREATE TABLE sales.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    order_number VARCHAR(20) NOT NULL,
    quote_id UUID REFERENCES sales.quotes(id),
    customer_id UUID REFERENCES sales.customers(id),
    contact_id UUID REFERENCES sales.customer_contacts(id),
    salesperson_id UUID REFERENCES sales.salespeople(id),
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    price_list_id UUID REFERENCES sales.price_lists(id),
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    exchange_rate DECIMAL(10, 4) DEFAULT 1,
    subtotal DECIMAL(19, 4) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    total DECIMAL(19, 4) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'confirmed', 'in_process', 'partially_shipped', 'shipped', 'partially_invoiced', 'invoiced', 'cancelled')),
    notes TEXT,
    shipping_address TEXT,
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),
    shipping_country VARCHAR(50),
    shipping_postal_code VARCHAR(20),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, order_number)
);

-- Líneas de pedido
CREATE TABLE sales.order_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES sales.orders(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    quote_line_id UUID REFERENCES sales.quote_lines(id),
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    shipped_quantity DECIMAL(19, 4) DEFAULT 0,
    invoiced_quantity DECIMAL(19, 4) DEFAULT 0,
    unit_price DECIMAL(19, 4) NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0,
    discount_amount DECIMAL(19, 4) DEFAULT 0,
    tax_percentage DECIMAL(5, 2) DEFAULT 0,
    tax_amount DECIMAL(19, 4) DEFAULT 0,
    subtotal DECIMAL(19, 4) NOT NULL,
    total DECIMAL(19, 4) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(order_id, line_number)
);

-- Entregas/Despachos
CREATE TABLE sales.shipments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    shipment_number VARCHAR(20) NOT NULL,
    order_id UUID REFERENCES sales.orders(id),
    customer_id UUID REFERENCES sales.customers(id),
    shipment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'in_process', 'shipped', 'delivered', 'cancelled')),
    tracking_number VARCHAR(50),
    carrier VARCHAR(50),
    shipping_cost DECIMAL(19, 4) DEFAULT 0,
    notes TEXT,
    shipping_address TEXT,
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),
    shipping_country VARCHAR(50),
    shipping_postal_code VARCHAR(20),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, shipment_number)
);

-- Líneas de entrega
CREATE TABLE sales.shipment_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_id UUID REFERENCES sales.shipments(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    order_line_id UUID REFERENCES sales.order_lines(id),
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    warehouse_id UUID REFERENCES inventory.warehouses(id),
    location_id UUID REFERENCES inventory.warehouse_locations(id),
    lot_number VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(shipment_id, line_number)
);

-- Facturas de venta
CREATE TABLE sales.invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    invoice_number VARCHAR(20) NOT NULL,
    order_id UUID REFERENCES sales.orders(id),
    customer_id UUID REFERENCES sales.customers(id),
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    exchange_rate DECIMAL(10, 4) DEFAULT 1,
    subtotal DECIMAL(19, 4) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    total DECIMAL(19, 4) NOT NULL DEFAULT 0,
    amount_paid DECIMAL(19, 4) DEFAULT 0,
    balance_due DECIMAL(19, 4) DEFAULT 0,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'issued', 'partially_paid', 'paid', 'overdue', 'cancelled')),
    payment_terms TEXT,
    notes TEXT,
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, invoice_number)
);

-- Líneas de factura
CREATE TABLE sales.invoice_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES sales.invoices(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    order_line_id UUID REFERENCES sales.order_lines(id),
    shipment_line_id UUID REFERENCES sales.shipment_lines(id),
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    unit_price DECIMAL(19, 4) NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0,
    discount_amount DECIMAL(19, 4) DEFAULT 0,
    tax_percentage DECIMAL(5, 2) DEFAULT 0,
    tax_amount DECIMAL(19, 4) DEFAULT 0,
    subtotal DECIMAL(19, 4) NOT NULL,
    total DECIMAL(19, 4) NOT NULL,
    accounting_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(invoice_id, line_number)
);

-- Impuestos de factura
CREATE TABLE sales.invoice_taxes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES sales.invoices(id) ON DELETE CASCADE,
    tax_id UUID REFERENCES accounting.tax_rates(id),
    tax_name VARCHAR(100) NOT NULL,
    tax_rate DECIMAL(5, 2) NOT NULL,
    taxable_amount DECIMAL(19, 4) NOT NULL,
    tax_amount DECIMAL(19, 4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Pagos de clientes
CREATE TABLE sales.customer_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    payment_number VARCHAR(20) NOT NULL,
    customer_id UUID REFERENCES sales.customers(id),
    payment_date DATE NOT NULL,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('cash', 'check', 'credit_card', 'bank_transfer', 'other')),
    amount DECIMAL(19, 4) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    exchange_rate DECIMAL(10, 4) DEFAULT 1,
    reference VARCHAR(50),
    notes TEXT,
    bank_account_id UUID REFERENCES finance.bank_accounts(id),
    transaction_id UUID REFERENCES finance.transactions(id),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, payment_number)
);

-- Aplicación de pagos a facturas
CREATE TABLE sales.payment_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID REFERENCES sales.customer_payments(id) ON DELETE CASCADE,
    invoice_id UUID REFERENCES sales.invoices(id) ON DELETE CASCADE,
    amount DECIMAL(19, 4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Notas de crédito
CREATE TABLE sales.credit_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    credit_note_number VARCHAR(20) NOT NULL,
    invoice_id UUID REFERENCES sales.invoices(id),
    customer_id UUID REFERENCES sales.customers(id),
    credit_note_date DATE NOT NULL,
    reason VARCHAR(100) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    exchange_rate DECIMAL(10, 4) DEFAULT 1,
    subtotal DECIMAL(19, 4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    total DECIMAL(19, 4) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'issued', 'applied', 'cancelled')),
    notes TEXT,
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, credit_note_number)
);

-- Líneas de nota de crédito
CREATE TABLE sales.credit_note_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    credit_note_id UUID REFERENCES sales.credit_notes(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    invoice_line_id UUID REFERENCES sales.invoice_lines(id),
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    unit_price DECIMAL(19, 4) NOT NULL,
    tax_percentage DECIMAL(5, 2) DEFAULT 0,
    tax_amount DECIMAL(19, 4) DEFAULT 0,
    subtotal DECIMAL(19, 4) NOT NULL,
    total DECIMAL(19, 4) NOT NULL,
    accounting_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(credit_note_id, line_number)
);

-- Aplicación de notas de crédito a facturas
CREATE TABLE sales.credit_note_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    credit_note_id UUID REFERENCES sales.credit_notes(id) ON DELETE CASCADE,
    invoice_id UUID REFERENCES sales.invoices(id) ON DELETE CASCADE,
    amount DECIMAL(19, 4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Comisiones de vendedores
CREATE TABLE sales.salesperson_commissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    salesperson_id UUID REFERENCES sales.salespeople(id),
    invoice_id UUID REFERENCES sales.invoices(id),
    commission_date DATE NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    percentage DECIMAL(5, 2) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('calculated', 'approved', 'paid', 'cancelled')),
    payment_id UUID REFERENCES finance.transactions(id),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Metas de ventas
CREATE TABLE sales.sales_targets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    salesperson_id UUID REFERENCES sales.salespeople(id),
    zone_id UUID REFERENCES sales.sales_zones(id),
    target_type VARCHAR(20) NOT NULL CHECK (target_type IN ('revenue', 'units', 'customers', 'profit')),
    period_month INTEGER CHECK (period_month BETWEEN 1 AND 12),
    period_year INTEGER NOT NULL,
    target_amount DECIMAL(19, 4) NOT NULL,
    actual_amount DECIMAL(19, 4) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Actividades de CRM
CREATE TABLE sales.crm_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES sales.customers(id),
    contact_id UUID REFERENCES sales.customer_contacts(id),
    salesperson_id UUID REFERENCES sales.salespeople(id),
    activity_type VARCHAR(20) NOT NULL CHECK (activity_type IN ('call', 'meeting', 'email', 'task', 'note')),
    subject VARCHAR(200) NOT NULL,
    description TEXT,
    activity_date TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER,
    status VARCHAR(20) NOT NULL CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')),
    priority VARCHAR(20) CHECK (priority IN ('low', 'medium', 'high')),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Oportunidades de venta
CREATE TABLE sales.sales_opportunities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES sales.customers(id),
    contact_id UUID REFERENCES sales.customer_contacts(id),
    salesperson_id UUID REFERENCES sales.salespeople(id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    expected_revenue DECIMAL(19, 4) NOT NULL,
    probability DECIMAL(5, 2) NOT NULL,
    expected_close_date DATE,
    stage VARCHAR(20) NOT NULL CHECK (stage IN ('prospecting', 'qualification', 'proposal', 'negotiation', 'closed_won', 'closed_lost')),
    source VARCHAR(50),
    notes TEXT,
    quote_id UUID REFERENCES sales.quotes(id),
    order_id UUID REFERENCES sales.orders(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Configuración de TPV (Terminal Punto de Venta)
CREATE TABLE sales.pos_terminals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Sesiones de TPV
CREATE TABLE sales.pos_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    terminal_id UUID REFERENCES sales.pos_terminals(id) ON DELETE CASCADE,
    user_id UUID REFERENCES core.users(id),
    opening_time TIMESTAMP WITH TIME ZONE NOT NULL,
    closing_time TIMESTAMP WITH TIME ZONE,
    opening_balance DECIMAL(19, 4) NOT NULL DEFAULT 0,
    closing_balance DECIMAL(19, 4),
    status VARCHAR(20) NOT NULL CHECK (status IN ('open', 'closed', 'balanced')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Ventas de TPV
CREATE TABLE sales.pos_sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    session_id UUID REFERENCES sales.pos_sessions(id),
    sale_number VARCHAR(20) NOT NULL,
    customer_id UUID REFERENCES sales.customers(id),
    sale_date TIMESTAMP WITH TIME ZONE NOT NULL,
    subtotal DECIMAL(19, 4) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    total DECIMAL(19, 4) NOT NULL DEFAULT 0,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('cash', 'credit_card', 'debit_card', 'check', 'other')),
    payment_reference VARCHAR(50),
    status VARCHAR(20) NOT NULL CHECK (status IN ('completed', 'refunded', 'partially_refunded')),
    invoice_id UUID REFERENCES sales.invoices(id),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, sale_number)
);

-- Líneas de venta de TPV
CREATE TABLE sales.pos_sale_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pos_sale_id UUID REFERENCES sales.pos_sales(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    unit_price DECIMAL(19, 4) NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0,
    discount_amount DECIMAL(19, 4) DEFAULT 0,
    tax_percentage DECIMAL(5, 2) DEFAULT 0,
    tax_amount DECIMAL(19, 4) DEFAULT 0,
    subtotal DECIMAL(19, 4) NOT NULL,
    total DECIMAL(19, 4) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(pos_sale_id, line_number)
);

-- Insertar datos iniciales

-- Categorías de clientes
INSERT INTO sales.customer_categories (company_id, code, name, description)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'REG', 'Regular', 'Clientes regulares'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'VIP', 'VIP', 'Clientes VIP'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'MAY', 'Mayorista', 'Clientes mayoristas'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'MIN', 'Minorista', 'Clientes minoristas');

-- Zonas de venta
INSERT INTO sales.sales_zones (company_id, code, name, description)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'NORTE', 'Zona Norte', 'Región norte del país'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SUR', 'Zona Sur', 'Región sur del país'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ESTE', 'Zona Este', 'Región este del país'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'OESTE', 'Zona Oeste', 'Región oeste del país'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CENTRO', 'Zona Centro', 'Región central del país');

-- Vendedores
INSERT INTO sales.salespeople (company_id, code, name, commission_rate)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'V001', 'Juan Pérez', 2.5),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'V002', 'María Gómez', 3.0),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'V003', 'Carlos Rodríguez', 2.0);

-- Listas de precios
INSERT INTO sales.price_lists (company_id, code, name, description, start_date, end_date)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'GEN', 'Lista General', 'Lista de precios general', '2025-01-01', '2025-12-31'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'MAY', 'Lista Mayoristas', 'Lista de precios para mayoristas', '2025-01-01', '2025-12-31'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ESP', 'Lista Especial', 'Lista de precios para clientes especiales', '2025-01-01', '2025-12-31');

-- Descuentos
INSERT INTO sales.discounts (company_id, code, name, discount_type, value, start_date, end_date)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'DESC10', 'Descuento 10%', 'percentage', 10, '2025-01-01', '2025-12-31'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'DESC20', 'Descuento 20%', 'percentage', 20, '2025-01-01', '2025-12-31'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'FIJO50K', 'Descuento Fijo $50,000', 'fixed_amount', 50000, '2025-01-01', '2025-12-31');

-- Terminales TPV
INSERT INTO sales.pos_terminals (company_id, branch_id, code, name, description)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 
     (SELECT id FROM core.branches WHERE name = 'Sucursal Principal' AND company_id = (SELECT id FROM core.companies WHERE name = 'Empresa Demo')), 
     'TPV001', 'Terminal 1', 'Terminal principal');

-- Clientes
INSERT INTO sales.customers (company_id, code, name, tax_id, customer_type, address, city, country, phone, email, credit_limit, payment_term_days)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'C001', 'Comercial ABC', '900123456-7', 'company', 'Calle 123 #45-67', 'Bogotá', 'Colombia', '601-1234567', 'contacto@comercialabc.com', 10000000, 30),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'C002', 'Distribuidora XYZ', '900234567-8', 'company', 'Avenida 45 #67-89', 'Medellín', 'Colombia', '604-2345678', 'info@distribuidoraxyz.com', 5000000, 15),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'C003', 'Juan Consumidor', '1234567890', 'individual', 'Carrera 78 #90-12', 'Cali', 'Colombia', '602-3456789', 'juan@example.com', 1000000, 0);

-- Contactos de clientes
INSERT INTO sales.customer_contacts (customer_id, first_name, last_name, position, email, phone, is_primary)
VALUES 
    ((SELECT id FROM sales.customers WHERE code = 'C001'), 'Pedro', 'Martínez', 'Gerente de Compras', 'pedro@comercialabc.com', '601-1234567 ext 101', TRUE),
    ((SELECT id FROM sales.customers WHERE code = 'C002'), 'Ana', 'Sánchez', 'Directora Comercial', 'ana@distribuidoraxyz.com', '604-2345678 ext 201', TRUE);

-- Asignación de categorías a clientes
INSERT INTO sales.customer_category_assignments (customer_id, category_id)
VALUES 
    ((SELECT id FROM sales.customers WHERE code = 'C001'), (SELECT id FROM sales.customer_categories WHERE code = 'MAY')),
    ((SELECT id FROM sales.customers WHERE code = 'C002'), (SELECT id FROM sales.customer_categories WHERE code = 'MAY')),
    ((SELECT id FROM sales.customers WHERE code = 'C003'), (SELECT id FROM sales.customer_categories WHERE code = 'MIN'));

-- Asignación de zonas a clientes
INSERT INTO sales.customer_zones (customer_id, zone_id)
VALUES 
    ((SELECT id FROM sales.customers WHERE code = 'C001'), (SELECT id FROM sales.sales_zones WHERE code = 'CENTRO')),
    ((SELECT id FROM sales.customers WHERE code = 'C002'), (SELECT id FROM sales.sales_zones WHERE code = 'NORTE')),
    ((SELECT id FROM sales.customers WHERE code = 'C003'), (SELECT id FROM sales.sales_zones WHERE code = 'SUR'));

-- Asignación de listas de precios a clientes
INSERT INTO sales.customer_price_lists (customer_id, price_list_id)
VALUES 
    ((SELECT id FROM sales.customers WHERE code = 'C001'), (SELECT id FROM sales.price_lists WHERE code = 'MAY')),
    ((SELECT id FROM sales.customers WHERE code = 'C002'), (SELECT id FROM sales.price_lists WHERE code = 'MAY')),
    ((SELECT id FROM sales.customers WHERE code = 'C003'), (SELECT id FROM sales.price_lists WHERE code = 'GEN'));

-- Asignación de vendedores a zonas
INSERT INTO sales.salesperson_zones (salesperson_id, zone_id)
VALUES 
    ((SELECT id FROM sales.salespeople WHERE code = 'V001'), (SELECT id FROM sales.sales_zones WHERE code = 'NORTE')),
    ((SELECT id FROM sales.salespeople WHERE code = 'V001'), (SELECT id FROM sales.sales_zones WHERE code = 'CENTRO')),
    ((SELECT id FROM sales.salespeople WHERE code = 'V002'), (SELECT id FROM sales.sales_zones WHERE code = 'SUR')),
    ((SELECT id FROM sales.salespeople WHERE code = 'V002'), (SELECT id FROM sales.sales_zones WHERE code = 'ESTE')),
    ((SELECT id FROM sales.salespeople WHERE code = 'V003'), (SELECT id FROM sales.sales_zones WHERE code = 'OESTE'));
 
