 -- Script de inicialización de tablas para el módulo de Inventarios

-- Unidades de medida
CREATE TABLE inventory.units_of_measure (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    is_base BOOLEAN DEFAULT FALSE,
    conversion_factor DECIMAL(19, 6) DEFAULT 1,
    base_unit_id UUID REFERENCES inventory.units_of_measure(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Categorías de productos
CREATE TABLE inventory.product_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES inventory.product_categories(id),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Marcas de productos
CREATE TABLE inventory.product_brands (
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

-- Productos
CREATE TABLE inventory.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    barcode VARCHAR(50),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES inventory.product_categories(id),
    brand_id UUID REFERENCES inventory.product_brands(id),
    unit_id UUID REFERENCES inventory.units_of_measure(id),
    purchase_unit_id UUID REFERENCES inventory.units_of_measure(id),
    sales_unit_id UUID REFERENCES inventory.units_of_measure(id),
    product_type VARCHAR(20) NOT NULL CHECK (product_type IN ('inventory', 'service', 'non_inventory')),
    is_purchasable BOOLEAN DEFAULT TRUE,
    is_sellable BOOLEAN DEFAULT TRUE,
    is_stockable BOOLEAN DEFAULT TRUE,
    min_stock DECIMAL(19, 4) DEFAULT 0,
    max_stock DECIMAL(19, 4),
    reorder_point DECIMAL(19, 4),
    reorder_qty DECIMAL(19, 4),
    lead_time_days INTEGER,
    standard_cost DECIMAL(19, 4),
    last_purchase_cost DECIMAL(19, 4),
    average_cost DECIMAL(19, 4),
    sales_price DECIMAL(19, 4),
    tax_id UUID REFERENCES accounting.tax_rates(id),
    purchase_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    inventory_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    sales_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    cogs_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    weight DECIMAL(10, 2),
    volume DECIMAL(10, 2),
    width DECIMAL(10, 2),
    height DECIMAL(10, 2),
    depth DECIMAL(10, 2),
    has_serial_numbers BOOLEAN DEFAULT FALSE,
    has_batch_numbers BOOLEAN DEFAULT FALSE,
    has_expiry_dates BOOLEAN DEFAULT FALSE,
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Variantes de productos
CREATE TABLE inventory.product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES inventory.products(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    attributes JSONB,
    barcode VARCHAR(50),
    additional_cost DECIMAL(19, 4) DEFAULT 0,
    additional_price DECIMAL(19, 4) DEFAULT 0,
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, code)
);

-- Atributos de productos
CREATE TABLE inventory.product_attributes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, name)
);

-- Valores de atributos
CREATE TABLE inventory.attribute_values (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attribute_id UUID REFERENCES inventory.product_attributes(id) ON DELETE CASCADE,
    value VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(attribute_id, value)
);

-- Almacenes
CREATE TABLE inventory.warehouses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES core.branches(id),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(100),
    manager_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Ubicaciones en almacén
CREATE TABLE inventory.warehouse_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_id UUID REFERENCES inventory.warehouses(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    aisle VARCHAR(20),
    rack VARCHAR(20),
    shelf VARCHAR(20),
    bin VARCHAR(20),
    is_receiving BOOLEAN DEFAULT FALSE,
    is_shipping BOOLEAN DEFAULT FALSE,
    is_quarantine BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(warehouse_id, code)
);

-- Stock de productos
CREATE TABLE inventory.product_stock (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    product_id UUID REFERENCES inventory.products(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES inventory.product_variants(id) ON DELETE CASCADE,
    warehouse_id UUID REFERENCES inventory.warehouses(id) ON DELETE CASCADE,
    location_id UUID REFERENCES inventory.warehouse_locations(id),
    quantity_on_hand DECIMAL(19, 4) NOT NULL DEFAULT 0,
    quantity_reserved DECIMAL(19, 4) NOT NULL DEFAULT 0,
    quantity_available DECIMAL(19, 4) NOT NULL DEFAULT 0,
    last_counted_date DATE,
    last_movement_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, product_id, variant_id, warehouse_id, location_id)
);

-- Lotes de productos
CREATE TABLE inventory.product_batches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    product_id UUID REFERENCES inventory.products(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES inventory.product_variants(id) ON DELETE CASCADE,
    batch_number VARCHAR(50) NOT NULL,
    manufacturing_date DATE,
    expiry_date DATE,
    supplier_id UUID REFERENCES purchases.suppliers(id),
    purchase_order_id UUID REFERENCES purchases.purchase_orders(id),
    receipt_id UUID REFERENCES purchases.goods_receipts(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, product_id, batch_number)
);

-- Stock por lotes
CREATE TABLE inventory.batch_stock (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    batch_id UUID REFERENCES inventory.product_batches(id) ON DELETE CASCADE,
    warehouse_id UUID REFERENCES inventory.warehouses(id) ON DELETE CASCADE,
    location_id UUID REFERENCES inventory.warehouse_locations(id),
    quantity_on_hand DECIMAL(19, 4) NOT NULL DEFAULT 0,
    quantity_reserved DECIMAL(19, 4) NOT NULL DEFAULT 0,
    quantity_available DECIMAL(19, 4) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(batch_id, warehouse_id, location_id)
);

-- Números de serie
CREATE TABLE inventory.serial_numbers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    product_id UUID REFERENCES inventory.products(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES inventory.product_variants(id) ON DELETE CASCADE,
    serial_number VARCHAR(50) NOT NULL,
    batch_id UUID REFERENCES inventory.product_batches(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('available', 'reserved', 'sold', 'defective', 'returned')),
    warehouse_id UUID REFERENCES inventory.warehouses(id),
    location_id UUID REFERENCES inventory.warehouse_locations(id),
    purchase_order_id UUID REFERENCES purchases.purchase_orders(id),
    receipt_id UUID REFERENCES purchases.goods_receipts(id),
    sales_order_id UUID REFERENCES sales.orders(id),
    shipment_id UUID REFERENCES sales.shipments(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, product_id, serial_number)
);

-- Tipos de movimientos de inventario
CREATE TABLE inventory.movement_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    affects_quantity BOOLEAN DEFAULT TRUE,
    direction VARCHAR(10) NOT NULL CHECK (direction IN ('in', 'out', 'transfer')),
    requires_document BOOLEAN DEFAULT FALSE,
    is_system BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Movimientos de inventario
CREATE TABLE inventory.inventory_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    movement_number VARCHAR(20) NOT NULL,
    movement_type_id UUID REFERENCES inventory.movement_types(id),
    movement_date TIMESTAMP WITH TIME ZONE NOT NULL,
    source_warehouse_id UUID REFERENCES inventory.warehouses(id),
    source_location_id UUID REFERENCES inventory.warehouse_locations(id),
    destination_warehouse_id UUID REFERENCES inventory.warehouses(id),
    destination_location_id UUID REFERENCES inventory.warehouse_locations(id),
    reference_type VARCHAR(50),
    reference_id UUID,
    notes TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'pending', 'completed', 'cancelled')),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, movement_number)
);

-- Líneas de movimiento de inventario
CREATE TABLE inventory.inventory_movement_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_id UUID REFERENCES inventory.inventory_movements(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    variant_id UUID REFERENCES inventory.product_variants(id),
    batch_id UUID REFERENCES inventory.product_batches(id),
    serial_id UUID REFERENCES inventory.serial_numbers(id),
    quantity DECIMAL(19, 4) NOT NULL,
    unit_cost DECIMAL(19, 4),
    total_cost DECIMAL(19, 4),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(movement_id, line_number)
);

-- Ajustes de inventario
CREATE TABLE inventory.inventory_adjustments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    adjustment_number VARCHAR(20) NOT NULL,
    adjustment_date DATE NOT NULL,
    warehouse_id UUID REFERENCES inventory.warehouses(id),
    reason VARCHAR(100) NOT NULL,
    notes TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'pending', 'approved', 'completed', 'cancelled')),
    movement_id UUID REFERENCES inventory.inventory_movements(id),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_by UUID REFERENCES core.users(id),
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, adjustment_number)
);

-- Líneas de ajuste de inventario
CREATE TABLE inventory.inventory_adjustment_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    adjustment_id UUID REFERENCES inventory.inventory_adjustments(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    variant_id UUID REFERENCES inventory.product_variants(id),
    location_id UUID REFERENCES inventory.warehouse_locations(id),
    batch_id UUID REFERENCES inventory.product_batches(id),
    serial_id UUID REFERENCES inventory.serial_numbers(id),
    current_quantity DECIMAL(19, 4) NOT NULL,
    new_quantity DECIMAL(19, 4) NOT NULL,
    adjustment_quantity DECIMAL(19, 4) NOT NULL,
    unit_cost DECIMAL(19, 4),
    total_cost DECIMAL(19, 4),
    reason VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(adjustment_id, line_number)
);

-- Transferencias de inventario
CREATE TABLE inventory.inventory_transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    transfer_number VARCHAR(20) NOT NULL,
    transfer_date DATE NOT NULL,
    source_warehouse_id UUID REFERENCES inventory.warehouses(id),
    destination_warehouse_id UUID REFERENCES inventory.warehouses(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'pending', 'in_transit', 'partially_received', 'completed', 'cancelled')),
    shipping_date DATE,
    expected_receipt_date DATE,
    actual_receipt_date DATE,
    notes TEXT,
    movement_id UUID REFERENCES inventory.inventory_movements(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, transfer_number)
);

-- Líneas de transferencia de inventario
CREATE TABLE inventory.inventory_transfer_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transfer_id UUID REFERENCES inventory.inventory_transfers(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    variant_id UUID REFERENCES inventory.product_variants(id),
    source_location_id UUID REFERENCES inventory.warehouse_locations(id),
    destination_location_id UUID REFERENCES inventory.warehouse_locations(id),
    batch_id UUID REFERENCES inventory.product_batches(id),
    serial_id UUID REFERENCES inventory.serial_numbers(id),
    quantity DECIMAL(19, 4) NOT NULL,
    received_quantity DECIMAL(19, 4) DEFAULT 0,
    unit_cost DECIMAL(19, 4),
    total_cost DECIMAL(19, 4),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(transfer_id, line_number)
);

-- Inventarios físicos
CREATE TABLE inventory.physical_inventories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    inventory_number VARCHAR(20) NOT NULL,
    inventory_date DATE NOT NULL,
    warehouse_id UUID REFERENCES inventory.warehouses(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')),
    notes TEXT,
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, inventory_number)
);

-- Conteos de inventario físico
CREATE TABLE inventory.physical_inventory_counts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inventory_id UUID REFERENCES inventory.physical_inventories(id) ON DELETE CASCADE,
    count_number INTEGER NOT NULL,
    count_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    notes TEXT,
    counted_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(inventory_id, count_number)
);

-- Líneas de conteo de inventario físico
CREATE TABLE inventory.physical_inventory_count_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    count_id UUID REFERENCES inventory.physical_inventory_counts(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    variant_id UUID REFERENCES inventory.product_variants(id),
    location_id UUID REFERENCES inventory.warehouse_locations(id),
    batch_id UUID REFERENCES inventory.product_batches(id),
    serial_id UUID REFERENCES inventory.serial_numbers(id),
    expected_quantity DECIMAL(19, 4) NOT NULL,
    counted_quantity DECIMAL(19, 4),
    difference DECIMAL(19, 4),
    unit_cost DECIMAL(19, 4),
    total_cost DECIMAL(19, 4),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(count_id, line_number)
);

-- Valoración de inventario
CREATE TABLE inventory.inventory_valuation (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    valuation_date DATE NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    variant_id UUID REFERENCES inventory.product_variants(id),
    warehouse_id UUID REFERENCES inventory.warehouses(id),
    quantity_on_hand DECIMAL(19, 4) NOT NULL,
    unit_cost DECIMAL(19, 4) NOT NULL,
    total_value DECIMAL(19, 4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, valuation_date, product_id, variant_id, warehouse_id)
);

-- Análisis ABC de inventario
CREATE TABLE inventory.abc_analysis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    analysis_date DATE NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    variant_id UUID REFERENCES inventory.product_variants(id),
    annual_usage_value DECIMAL(19, 4) NOT NULL,
    percentage_of_total DECIMAL(5, 2) NOT NULL,
    cumulative_percentage DECIMAL(5, 2) NOT NULL,
    abc_class CHAR(1) NOT NULL CHECK (abc_class IN ('A', 'B', 'C')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, analysis_date, product_id, variant_id)
);

-- Kits de productos
CREATE TABLE inventory.product_kits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    kit_product_id UUID REFERENCES inventory.products(id),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Componentes de kits
CREATE TABLE inventory.kit_components (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kit_id UUID REFERENCES inventory.product_kits(id) ON DELETE CASCADE,
    component_product_id UUID REFERENCES inventory.products(id),
    component_variant_id UUID REFERENCES inventory.product_variants(id),
    quantity DECIMAL(19, 4) NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Ensamblaje de kits
CREATE TABLE inventory.kit_assemblies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    assembly_number VARCHAR(20) NOT NULL,
    kit_id UUID REFERENCES inventory.product_kits(id),
    assembly_date DATE NOT NULL,
    warehouse_id UUID REFERENCES inventory.warehouses(id),
    quantity DECIMAL(19, 4) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'in_progress', 'completed', 'cancelled')),
    notes TEXT,
    movement_id UUID REFERENCES inventory.inventory_movements(id),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    created_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, assembly_number)
);

-- Líneas de ensamblaje de kits
CREATE TABLE inventory.kit_assembly_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assembly_id UUID REFERENCES inventory.kit_assemblies(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    component_product_id UUID REFERENCES inventory.products(id),
    component_variant_id UUID REFERENCES inventory.product_variants(id),
    location_id UUID REFERENCES inventory.warehouse_locations(id),
    batch_id UUID REFERENCES inventory.product_batches(id),
    serial_id UUID REFERENCES inventory.serial_numbers(id),
    required_quantity DECIMAL(19, 4) NOT NULL,
    used_quantity DECIMAL(19, 4) NOT NULL,
    unit_cost DECIMAL(19, 4),
    total_cost DECIMAL(19, 4),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(assembly_id, line_number)
);

-- Calidad de inventario
CREATE TABLE inventory.quality_control (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    qc_number VARCHAR(20) NOT NULL,
    qc_date DATE NOT NULL,
    product_id UUID REFERENCES inventory.products(id),
    variant_id UUID REFERENCES inventory.product_variants(id),
    batch_id UUID REFERENCES inventory.product_batches(id),
    serial_id UUID REFERENCES inventory.serial_numbers(id),
    warehouse_id UUID REFERENCES inventory.warehouses(id),
    location_id UUID REFERENCES inventory.warehouse_locations(id),
    reference_type VARCHAR(50),
    reference_id UUID,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'passed', 'failed', 'partially_passed')),
    notes TEXT,
    inspected_by UUID REFERENCES core.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, qc_number)
);

-- Criterios de control de calidad
CREATE TABLE inventory.quality_control_criteria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    qc_id UUID REFERENCES inventory.quality_control(id) ON DELETE CASCADE,
    criterion_name VARCHAR(100) NOT NULL,
    expected_value TEXT,
    actual_value TEXT,
    is_passed BOOLEAN,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos iniciales

-- Unidades de medida
INSERT INTO inventory.units_of_measure (company_id, code, name, symbol, is_base)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'UND', 'Unidad', 'und', TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'KG', 'Kilogramo', 'kg', TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'LT', 'Litro', 'lt', TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'MT', 'Metro', 'm', TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'GR', 'Gramo', 'g', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ML', 'Mililitro', 'ml', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CM', 'Centímetro', 'cm', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'DOC', 'Docena', 'doc', FALSE);

-- Actualizar unidades derivadas
UPDATE inventory.units_of_measure SET base_unit_id = (SELECT id FROM inventory.units_of_measure WHERE code = 'KG'), conversion_factor = 0.001 WHERE code = 'GR';
UPDATE inventory.units_of_measure SET base_unit_id = (SELECT id FROM inventory.units_of_measure WHERE code = 'LT'), conversion_factor = 0.001 WHERE code = 'ML';
UPDATE inventory.units_of_measure SET base_unit_id = (SELECT id FROM inventory.units_of_measure WHERE code = 'MT'), conversion_factor = 0.01 WHERE code = 'CM';
UPDATE inventory.units_of_measure SET base_unit_id = (SELECT id FROM inventory.units_of_measure WHERE code = 'UND'), conversion_factor = 12 WHERE code = 'DOC';

-- Categorías de productos
INSERT INTO inventory.product_categories (company_id, code, name, description)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'MP', 'Materias Primas', 'Materiales utilizados en la producción'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PT', 'Productos Terminados', 'Productos listos para la venta'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SV', 'Servicios', 'Servicios ofrecidos'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'EM', 'Empaques', 'Materiales de empaque'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RP', 'Repuestos', 'Repuestos y accesorios');

-- Marcas de productos
INSERT INTO inventory.product_brands (company_id, code, name, description)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'GEN', 'Genérico', 'Productos sin marca específica'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PRO', 'Propia', 'Marca propia de la empresa'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'IMP', 'Importado', 'Productos importados');

-- Tipos de movimientos de inventario
INSERT INTO inventory.movement_types (company_id, code, name, affects_quantity, direction, requires_document, is_system)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'COMP', 'Compra', TRUE, 'in', TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'VENT', 'Venta', TRUE, 'out', TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'TRAN', 'Transferencia', TRUE, 'transfer', TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'AJUP', 'Ajuste Positivo', TRUE, 'in', TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'AJDN', 'Ajuste Negativo', TRUE, 'out', TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PROD', 'Producción', TRUE, 'in', TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CONS', 'Consumo', TRUE, 'out', TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'DEVO', 'Devolución', TRUE, 'in', TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'DESP', 'Desperdicio', TRUE, 'out', FALSE, TRUE);

-- Almacenes
INSERT INTO inventory.warehouses (company_id, branch_id, code, name, description, address, city, country)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 
     (SELECT id FROM core.branches WHERE name = 'Sucursal Principal' AND company_id = (SELECT id FROM core.companies WHERE name = 'Empresa Demo')), 
     'ALM01', 'Almacén Principal', 'Almacén principal de la empresa', 'Calle 123 #45-67', 'Bogotá', 'Colombia'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 
     (SELECT id FROM core.branches WHERE name = 'Sucursal Principal' AND company_id = (SELECT id FROM core.companies WHERE name = 'Empresa Demo')), 
     'ALM02', 'Almacén Secundario', 'Almacén secundario de la empresa', 'Calle 123 #45-67', 'Bogotá', 'Colombia');

-- Ubicaciones en almacén
INSERT INTO inventory.warehouse_locations (warehouse_id, code, name, description, aisle, rack, shelf, is_receiving, is_shipping)
VALUES 
    ((SELECT id FROM inventory.warehouses WHERE code = 'ALM01'), 'REC', 'Recepción', 'Área de recepción de mercancía', 'A', '01', '01', TRUE, FALSE),
    ((SELECT id FROM inventory.warehouses WHERE code = 'ALM01'), 'DES', 'Despacho', 'Área de despacho de mercancía', 'B', '01', '01', FALSE, TRUE),
    ((SELECT id FROM inventory.warehouses WHERE code = 'ALM01'), 'A01', 'Ubicación A-01', 'Pasillo A, Estante 01', 'A', '01', '01', FALSE, FALSE),
    ((SELECT id FROM inventory.warehouses WHERE code = 'ALM01'), 'A02', 'Ubicación A-02', 'Pasillo A, Estante 02', 'A', '02', '01', FALSE, FALSE),
    ((SELECT id FROM inventory.warehouses WHERE code = 'ALM01'), 'B01', 'Ubicación B-01', 'Pasillo B, Estante 01', 'B', '01', '01', FALSE, FALSE),
    ((SELECT id FROM inventory.warehouses WHERE code = 'ALM02'), 'REC', 'Recepción', 'Área de recepción de mercancía', 'A', '01', '01', TRUE, FALSE),
    ((SELECT id FROM inventory.warehouses WHERE code = 'ALM02'), 'DES', 'Despacho', 'Área de despacho de mercancía', 'B', '01', '01', FALSE, TRUE),
    ((SELECT id FROM inventory.warehouses WHERE code = 'ALM02'), 'C01', 'Ubicación C-01', 'Pasillo C, Estante 01', 'C', '01', '01', FALSE, FALSE);

-- Productos
INSERT INTO inventory.products (company_id, code, name, description, category_id, brand_id, unit_id, product_type, is_purchasable, is_sellable, is_stockable, min_stock, reorder_point)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'P001', 'Producto 1', 'Descripción del producto 1', 
     (SELECT id FROM inventory.product_categories WHERE code = 'PT'), 
     (SELECT id FROM inventory.product_brands WHERE code = 'PRO'), 
     (SELECT id FROM inventory.units_of_measure WHERE code = 'UND'), 
     'inventory', TRUE, TRUE, TRUE, 10, 20),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'P002', 'Producto 2', 'Descripción del producto 2', 
     (SELECT id FROM inventory.product_categories WHERE code = 'PT'), 
     (SELECT id FROM inventory.product_brands WHERE code = 'PRO'), 
     (SELECT id FROM inventory.units_of_measure WHERE code = 'UND'), 
     'inventory', TRUE, TRUE, TRUE, 5, 10),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'MP001', 'Materia Prima 1', 'Descripción de la materia prima 1', 
     (SELECT id FROM inventory.product_categories WHERE code = 'MP'), 
     (SELECT id FROM inventory.product_brands WHERE code = 'GEN'), 
     (SELECT id FROM inventory.units_of_measure WHERE code = 'KG'), 
     'inventory', TRUE, FALSE, TRUE, 100, 200),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SV001', 'Servicio 1', 'Descripción del servicio 1', 
     (SELECT id FROM inventory.product_categories WHERE code = 'SV'), 
     (SELECT id FROM inventory.product_brands WHERE code = 'PRO'), 
     (SELECT id FROM inventory.units_of_measure WHERE code = 'UND'), 
     'service', FALSE, TRUE, FALSE, 0, 0);

-- Stock inicial
INSERT INTO inventory.product_stock (company_id, product_id, warehouse_id, location_id, quantity_on_hand, quantity_available)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 
     (SELECT id FROM inventory.products WHERE code = 'P001'), 
     (SELECT id FROM inventory.warehouses WHERE code = 'ALM01'), 
     (SELECT id FROM inventory.warehouse_locations WHERE code = 'A01' AND warehouse_id = (SELECT id FROM inventory.warehouses WHERE code = 'ALM01')), 
     50, 50),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 
     (SELECT id FROM inventory.products WHERE code = 'P002'), 
     (SELECT id FROM inventory.warehouses WHERE code = 'ALM01'), 
     (SELECT id FROM inventory.warehouse_locations WHERE code = 'A02' AND warehouse_id = (SELECT id FROM inventory.warehouses WHERE code = 'ALM01')), 
     30, 30),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 
     (SELECT id FROM inventory.products WHERE code = 'MP001'), 
     (SELECT id FROM inventory.warehouses WHERE code = 'ALM01'), 
     (SELECT id FROM inventory.warehouse_locations WHERE code = 'B01' AND warehouse_id = (SELECT id FROM inventory.warehouses WHERE code = 'ALM01')), 
     500, 500);

-- Atributos de productos
INSERT INTO inventory.product_attributes (company_id, name, description)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Color', 'Color del producto'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Tamaño', 'Tamaño del producto'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Material', 'Material del producto');

-- Valores de atributos
INSERT INTO inventory.attribute_values (attribute_id, value)
VALUES 
    ((SELECT id FROM inventory.product_attributes WHERE name = 'Color'), 'Rojo'),
    ((SELECT id FROM inventory.product_attributes WHERE name = 'Color'), 'Azul'),
    ((SELECT id FROM inventory.product_attributes WHERE name = 'Color'), 'Verde'),
    ((SELECT id FROM inventory.product_attributes WHERE name = 'Tamaño'), 'Pequeño'),
    ((SELECT id FROM inventory.product_attributes WHERE name = 'Tamaño'), 'Mediano'),
    ((SELECT id FROM inventory.product_attributes WHERE name = 'Tamaño'), 'Grande'),
    ((SELECT id FROM inventory.product_attributes WHERE name = 'Material'), 'Plástico'),
    ((SELECT id FROM inventory.product_attributes WHERE name = 'Material'), 'Metal'),
    ((SELECT id FROM inventory.product_attributes WHERE name = 'Material'), 'Madera');

