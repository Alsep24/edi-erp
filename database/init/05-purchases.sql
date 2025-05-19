 -- Script de inicialización de tablas para el módulo de Compras

-- Proveedores
CREATE TABLE purchases.suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    tax_id VARCHAR(20),
    supplier_type VARCHAR(20) NOT NULL CHECK (supplier_type IN ('company', 'individual', 'government')),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    payment_term_days INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Contactos de proveedores
CREATE TABLE purchases.supplier_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier_id UUID REFERENCES purchases.suppliers(id) ON DELETE CASCADE,
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

-- Categorías de proveedores
CREATE TABLE purchases.supplier_categories (
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

-- Relación entre proveedores y categorías
CREATE TABLE purchases.supplier_category_assignments (
    supplier_id UUID REFERENCES purchases.suppliers(id) ON DELETE CASCADE,
    category_id UUID REFERENCES purchases.supplier_categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (supplier_id, category_id)
);

-- Productos por proveedor
CREATE TABLE purchases.supplier_products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier_id UUID REFERENCES purchases.suppliers(id) ON DELETE CASCADE,
    product_id UUID REFERENCES inventory.products(id) ON DELETE CASCADE,
    supplier_product_code VARCHAR(50),
    supplier_product_name VARCHAR(100),
    purchase_price DECIMAL(19, 4) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    min_order_quantity DECIMAL(19, 4) DEFAULT 1,
    lead_time_days INTEGER,
    is_preferred BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(supplier_id, product_id)
);

-- Solicitudes de cotización
CREATE TABLE purchases.request_for_quotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    rfq_number VARCHAR(20) NOT NULL,
    request_date DATE NOT NULL,
    required_date DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'sent', 'closed', 'cancelled')),
    notes TEXT,
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, rfq_number)
);

-- Líneas de solicitud de cotización
CREATE TABLE purchases.rfq_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rfq_id UUID REFERENCES purchases.request_for_quotations(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    required_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(rfq_id, line_number)
);

-- Proveedores de solicitud de cotización
CREATE TABLE purchases.rfq_suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rfq_id UUID REFERENCES purchases.request_for_quotations(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES purchases.suppliers(id),
    sent_date DATE,
    response_deadline DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'sent', 'received', 'selected', 'rejected')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(rfq_id, supplier_id)
);

-- Cotizaciones de proveedores
CREATE TABLE purchases.supplier_quotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    rfq_supplier_id UUID REFERENCES purchases.rfq_suppliers(id),
    supplier_id UUID REFERENCES purchases.suppliers(id),
    quotation_number VARCHAR(50),
    quotation_date DATE NOT NULL,
    valid_until DATE,
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    exchange_rate DECIMAL(10, 4) DEFAULT 1,
    subtotal DECIMAL(19, 4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    total DECIMAL(19, 4) NOT NULL DEFAULT 0,
    delivery_time_days INTEGER,
    payment_terms TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('received', 'under_review', 'accepted', 'rejected')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Líneas de cotización de proveedores
CREATE TABLE purchases.supplier_quotation_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quotation_id UUID REFERENCES purchases.supplier_quotations(id) ON DELETE CASCADE,
    rfq_line_id UUID REFERENCES purchases.rfq_lines(id),
    line_number INTEGER NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    unit_price DECIMAL(19, 4) NOT NULL,
    tax_percentage DECIMAL(5, 2) DEFAULT 0,
    tax_amount DECIMAL(19, 4) DEFAULT 0,
    subtotal DECIMAL(19, 4) NOT NULL,
    total DECIMAL(19, 4) NOT NULL,
    delivery_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(quotation_id, line_number)
);

-- Órdenes de compra
CREATE TABLE purchases.purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    order_number VARCHAR(20) NOT NULL,
    supplier_id UUID REFERENCES purchases.suppliers(id),
    supplier_quotation_id UUID REFERENCES purchases.supplier_quotations(id),
    contact_id UUID REFERENCES purchases.supplier_contacts(id),
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    exchange_rate DECIMAL(10, 4) DEFAULT 1,
    subtotal DECIMAL(19, 4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    total DECIMAL(19, 4) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'sent', 'confirmed', 'partially_received', 'received', 'partially_invoiced', 'invoiced', 'cancelled')),
    payment_terms TEXT,
    shipping_terms TEXT,
    notes TEXT,
    shipping_address TEXT,
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),
    shipping_country VARCHAR(50),
    shipping_postal_code VARCHAR(20),
    approval_status VARCHAR(20) NOT NULL CHECK (approval_status IN ('pending', 'approved', 'rejected')),
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, order_number)
);

-- Líneas de orden de compra
CREATE TABLE purchases.purchase_order_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES purchases.purchase_orders(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    quotation_line_id UUID REFERENCES purchases.supplier_quotation_lines(id),
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    received_quantity DECIMAL(19, 4) DEFAULT 0,
    invoiced_quantity DECIMAL(19, 4) DEFAULT 0,
    unit_price DECIMAL(19, 4) NOT NULL,
    tax_percentage DECIMAL(5, 2) DEFAULT 0,
    tax_amount DECIMAL(19, 4) DEFAULT 0,
    subtotal DECIMAL(19, 4) NOT NULL,
    total DECIMAL(19, 4) NOT NULL,
    expected_delivery_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(order_id, line_number)
);

-- Recepciones de mercancía
CREATE TABLE purchases.goods_receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    receipt_number VARCHAR(20) NOT NULL,
    order_id UUID REFERENCES purchases.purchase_orders(id),
    supplier_id UUID REFERENCES purchases.suppliers(id),
    receipt_date DATE NOT NULL,
    delivery_note_number VARCHAR(50),
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'in_process', 'completed', 'cancelled')),
    notes TEXT,
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, receipt_number)
);

-- Líneas de recepción de mercancía
CREATE TABLE purchases.goods_receipt_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receipt_id UUID REFERENCES purchases.goods_receipts(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    order_line_id UUID REFERENCES purchases.purchase_order_lines(id),
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    warehouse_id UUID REFERENCES inventory.warehouses(id),
    location_id UUID REFERENCES inventory.warehouse_locations(id),
    lot_number VARCHAR(50),
    expiry_date DATE,
    quality_check_status VARCHAR(20) CHECK (quality_check_status IN ('pending', 'passed', 'failed')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(receipt_id, line_number)
);

-- Facturas de proveedores
CREATE TABLE purchases.supplier_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    invoice_number VARCHAR(50) NOT NULL,
    supplier_id UUID REFERENCES purchases.suppliers(id),
    order_id UUID REFERENCES purchases.purchase_orders(id),
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    exchange_rate DECIMAL(10, 4) DEFAULT 1,
    subtotal DECIMAL(19, 4) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    total DECIMAL(19, 4) NOT NULL DEFAULT 0,
    amount_paid DECIMAL(19, 4) DEFAULT 0,
    balance_due DECIMAL(19, 4) DEFAULT 0,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'registered', 'partially_paid', 'paid', 'overdue', 'cancelled')),
    payment_terms TEXT,
    notes TEXT,
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, supplier_id, invoice_number)
);

-- Líneas de factura de proveedores
CREATE TABLE purchases.supplier_invoice_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES purchases.supplier_invoices(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    order_line_id UUID REFERENCES purchases.purchase_order_lines(id),
    receipt_line_id UUID REFERENCES purchases.goods_receipt_lines(id),
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
    UNIQUE(invoice_id, line_number)
);

-- Impuestos de factura de proveedores
CREATE TABLE purchases.supplier_invoice_taxes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES purchases.supplier_invoices(id) ON DELETE CASCADE,
    tax_id UUID REFERENCES accounting.tax_rates(id),
    tax_name VARCHAR(100) NOT NULL,
    tax_rate DECIMAL(5, 2) NOT NULL,
    taxable_amount DECIMAL(19, 4) NOT NULL,
    tax_amount DECIMAL(19, 4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Pagos a proveedores
CREATE TABLE purchases.supplier_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    payment_number VARCHAR(20) NOT NULL,
    supplier_id UUID REFERENCES purchases.suppliers(id),
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

-- Aplicación de pagos a facturas de proveedores
CREATE TABLE purchases.payment_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID REFERENCES purchases.supplier_payments(id) ON DELETE CASCADE,
    invoice_id UUID REFERENCES purchases.supplier_invoices(id) ON DELETE CASCADE,
    amount DECIMAL(19, 4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Notas de débito
CREATE TABLE purchases.debit_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    debit_note_number VARCHAR(20) NOT NULL,
    invoice_id UUID REFERENCES purchases.supplier_invoices(id),
    supplier_id UUID REFERENCES purchases.suppliers(id),
    debit_note_date DATE NOT NULL,
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
    UNIQUE(company_id, debit_note_number)
);

-- Líneas de nota de débito
CREATE TABLE purchases.debit_note_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    debit_note_id UUID REFERENCES purchases.debit_notes(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    invoice_line_id UUID REFERENCES purchases.supplier_invoice_lines(id),
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
    UNIQUE(debit_note_id, line_number)
);

-- Aplicación de notas de débito a facturas
CREATE TABLE purchases.debit_note_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    debit_note_id UUID REFERENCES purchases.debit_notes(id) ON DELETE CASCADE,
    invoice_id UUID REFERENCES purchases.supplier_invoices(id) ON DELETE CASCADE,
    amount DECIMAL(19, 4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Contratos con proveedores
CREATE TABLE purchases.supplier_contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    contract_number VARCHAR(50) NOT NULL,
    supplier_id UUID REFERENCES purchases.suppliers(id),
    start_date DATE NOT NULL,
    end_date DATE,
    contract_type VARCHAR(50) NOT NULL,
    description TEXT,
    total_amount DECIMAL(19, 4),
    currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    payment_terms TEXT,
    renewal_terms TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'active', 'expired', 'terminated', 'renewed')),
    notes TEXT,
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, contract_number)
);

-- Productos en contratos
CREATE TABLE purchases.contract_products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_id UUID REFERENCES purchases.supplier_contracts(id) ON DELETE CASCADE,
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4),
    unit_price DECIMAL(19, 4) NOT NULL,
    start_date DATE,
    end_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Evaluación de proveedores
CREATE TABLE purchases.supplier_evaluations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES purchases.suppliers(id),
    evaluation_date DATE NOT NULL,
    evaluation_period_start DATE,
    evaluation_period_end DATE,
    quality_score DECIMAL(5, 2),
    delivery_score DECIMAL(5, 2),
    price_score DECIMAL(5, 2),
    service_score DECIMAL(5, 2),
    overall_score DECIMAL(5, 2),
    comments TEXT,
    evaluated_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Planificación de compras
CREATE TABLE purchases.purchase_planning (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    plan_number VARCHAR(20) NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    plan_period_start DATE NOT NULL,
    plan_period_end DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'approved', 'in_progress', 'completed', 'cancelled')),
    description TEXT,
    notes TEXT,
    created_by UUID REFERENCES core.users(id),
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, plan_number)
);

-- Líneas de planificación de compras
CREATE TABLE purchases.purchase_planning_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    planning_id UUID REFERENCES purchases.purchase_planning(id) ON DELETE CASCADE,
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    planned_quantity DECIMAL(19, 4) NOT NULL,
    estimated_unit_price DECIMAL(19, 4),
    estimated_total DECIMAL(19, 4),
    supplier_id UUID REFERENCES purchases.suppliers(id),
    required_date DATE,
    notes TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('planned', 'in_progress', 'ordered', 'received', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Solicitudes de compra
CREATE TABLE purchases.purchase_requisitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    requisition_number VARCHAR(20) NOT NULL,
    requisition_date DATE NOT NULL,
    required_date DATE,
    requested_by UUID REFERENCES core.users(id),
    department VARCHAR(50),
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'submitted', 'approved', 'rejected', 'ordered', 'partially_ordered', 'completed', 'cancelled')),
    notes TEXT,
    created_by UUID REFERENCES core.users(id),
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, requisition_number)
);

-- Líneas de solicitud de compra
CREATE TABLE purchases.purchase_requisition_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requisition_id UUID REFERENCES purchases.purchase_requisitions(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    description TEXT NOT NULL,
    quantity DECIMAL(19, 4) NOT NULL,
    ordered_quantity DECIMAL(19, 4) DEFAULT 0,
    estimated_unit_price DECIMAL(19, 4),
    required_date DATE,
    notes TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'approved', 'rejected', 'ordered', 'received')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(requisition_id, line_number)
);

-- Insertar datos iniciales

-- Categorías de proveedores
INSERT INTO purchases.supplier_categories (company_id, code, name, description)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'MAT', 'Materias Primas', 'Proveedores de materias primas'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SERV', 'Servicios', 'Proveedores de servicios'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'EQUIP', 'Equipos', 'Proveedores de equipos y maquinaria'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'TRANS', 'Transporte', 'Proveedores de servicios de transporte');

-- Proveedores
INSERT INTO purchases.suppliers (company_id, code, name, tax_id, supplier_type, address, city, country, phone, email, payment_term_days)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'P001', 'Suministros Industriales S.A.', '900345678-9', 'company', 'Calle 78 #45-67', 'Bogotá', 'Colombia', '601-3456789', 'contacto@suministrosindustriales.com', 30),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'P002', 'Materias Primas del Valle', '900456789-0', 'company', 'Avenida 5N #23-45', 'Cali', 'Colombia', '602-4567890', 'info@mpvalle.com', 45),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'P003', 'Transportes Rápidos', '900567890-1', 'company', 'Carrera 50 #10-15', 'Medellín', 'Colombia', '604-5678901', 'ventas@transportesrapidos.com', 15);

-- Contactos de proveedores
INSERT INTO purchases.supplier_contacts (supplier_id, first_name, last_name, position, email, phone, is_primary)
VALUES 
    ((SELECT id FROM purchases.suppliers WHERE code = 'P001'), 'Carlos', 'Ramírez', 'Gerente de Ventas', 'carlos@suministrosindustriales.com', '601-3456789 ext 101', TRUE),
    ((SELECT id FROM purchases.suppliers WHERE code = 'P002'), 'Laura', 'Gómez', 'Ejecutiva de Cuenta', 'laura@mpvalle.com', '602-4567890 ext 201', TRUE),
    ((SELECT id FROM purchases.suppliers WHERE code = 'P003'), 'Roberto', 'Sánchez', 'Director Comercial', 'roberto@transportesrapidos.com', '604-5678901 ext 301', TRUE);

-- Asignación de categorías a proveedores
INSERT INTO purchases.supplier_category_assignments (supplier_id, category_id)
VALUES 
    ((SELECT id FROM purchases.suppliers WHERE code = 'P001'), (SELECT id FROM purchases.supplier_categories WHERE code = 'MAT')),
    ((SELECT id FROM purchases.suppliers WHERE code = 'P001'), (SELECT id FROM purchases.supplier_categories WHERE code = 'EQUIP')),
    ((SELECT id FROM purchases.suppliers WHERE code = 'P002'), (SELECT id FROM purchases.supplier_categories WHERE code = 'MAT')),
    ((SELECT id FROM purchases.suppliers WHERE code = 'P003'), (SELECT id FROM purchases.supplier_categories WHERE code = 'TRANS'));

