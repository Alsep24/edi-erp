 -- Script de inicialización de tablas para el módulo de Nómina

-- Departamentos
CREATE TABLE payroll.departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    manager_id UUID REFERENCES core.users(id),
    parent_id UUID REFERENCES payroll.departments(id),
    cost_center_id UUID REFERENCES accounting.cost_centers(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Cargos
CREATE TABLE payroll.positions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    department_id UUID REFERENCES payroll.departments(id),
    description TEXT,
    min_salary DECIMAL(19, 4),
    max_salary DECIMAL(19, 4),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Empleados
CREATE TABLE payroll.employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    user_id UUID REFERENCES core.users(id),
    employee_code VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    identification_type VARCHAR(20) NOT NULL,
    identification_number VARCHAR(20) NOT NULL,
    birth_date DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    marital_status VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    email VARCHAR(100),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    blood_type VARCHAR(10),
    hire_date DATE NOT NULL,
    termination_date DATE,
    position_id UUID REFERENCES payroll.positions(id),
    department_id UUID REFERENCES payroll.departments(id),
    manager_id UUID REFERENCES payroll.employees(id),
    employment_type VARCHAR(20) NOT NULL CHECK (employment_type IN ('full_time', 'part_time', 'temporary', 'contractor')),
    employment_status VARCHAR(20) NOT NULL CHECK (employment_status IN ('active', 'on_leave', 'terminated')),
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    bank_account_type VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, employee_code),
    UNIQUE(company_id, identification_number)
);

-- Dependientes de empleados
CREATE TABLE payroll.employee_dependents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    relationship VARCHAR(20) NOT NULL,
    birth_date DATE,
    identification_number VARCHAR(20),
    is_beneficiary BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Documentos de empleados
CREATE TABLE payroll.employee_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    document_number VARCHAR(50),
    issue_date DATE,
    expiry_date DATE,
    issuing_authority VARCHAR(100),
    document_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Educación de empleados
CREATE TABLE payroll.employee_education (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    institution VARCHAR(100) NOT NULL,
    degree VARCHAR(100) NOT NULL,
    field_of_study VARCHAR(100),
    start_date DATE,
    end_date DATE,
    is_completed BOOLEAN DEFAULT TRUE,
    grade VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Experiencia laboral de empleados
CREATE TABLE payroll.employee_work_experience (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    company_name VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    responsibilities TEXT,
    reference_name VARCHAR(100),
    reference_contact VARCHAR(100),
    reason_for_leaving TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Habilidades de empleados
CREATE TABLE payroll.employee_skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    skill_name VARCHAR(100) NOT NULL,
    proficiency_level VARCHAR(20) NOT NULL CHECK (proficiency_level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    years_of_experience INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Contratos de empleados
CREATE TABLE payroll.employee_contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    contract_number VARCHAR(50) NOT NULL,
    contract_type VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    is_indefinite BOOLEAN DEFAULT FALSE,
    base_salary DECIMAL(19, 4) NOT NULL,
    salary_currency VARCHAR(3) NOT NULL DEFAULT 'COP',
    salary_period VARCHAR(20) NOT NULL CHECK (salary_period IN ('hourly', 'daily', 'weekly', 'biweekly', 'monthly')),
    working_hours_per_week DECIMAL(5, 2),
    trial_period_months INTEGER,
    notice_period_days INTEGER,
    benefits_package TEXT,
    signed_date DATE,
    termination_date DATE,
    termination_reason VARCHAR(100),
    document_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tipos de ausencia
CREATE TABLE payroll.absence_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_paid BOOLEAN DEFAULT TRUE,
    affects_payroll BOOLEAN DEFAULT TRUE,
    max_days_per_year INTEGER,
    requires_approval BOOLEAN DEFAULT TRUE,
    requires_documentation BOOLEAN DEFAULT FALSE,
    color VARCHAR(7),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Ausencias de empleados
CREATE TABLE payroll.employee_absences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    absence_type_id UUID REFERENCES payroll.absence_types(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    start_half_day BOOLEAN DEFAULT FALSE,
    end_half_day BOOLEAN DEFAULT FALSE,
    total_days DECIMAL(5, 2) NOT NULL,
    reason TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (start_date <= end_date)
);

-- Horarios de trabajo
CREATE TABLE payroll.work_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Detalles de horarios de trabajo
CREATE TABLE payroll.work_schedule_details (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    schedule_id UUID REFERENCES payroll.work_schedules(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    is_workday BOOLEAN DEFAULT TRUE,
    start_time TIME,
    end_time TIME,
    break_start_time TIME,
    break_end_time TIME,
    total_hours DECIMAL(5, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(schedule_id, day_of_week)
);

-- Asignación de horarios a empleados
CREATE TABLE payroll.employee_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    schedule_id UUID REFERENCES payroll.work_schedules(id),
    effective_date DATE NOT NULL,
    end_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Registro de tiempo
CREATE TABLE payroll.time_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    clock_in TIME NOT NULL,
    clock_out TIME,
    break_start TIME,
    break_end TIME,
    total_hours DECIMAL(5, 2),
    is_approved BOOLEAN DEFAULT FALSE,
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tipos de ingresos
CREATE TABLE payroll.income_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_taxable BOOLEAN DEFAULT TRUE,
    affects_social_security BOOLEAN DEFAULT TRUE,
    is_fixed BOOLEAN DEFAULT TRUE,
    accounting_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Tipos de deducciones
CREATE TABLE payroll.deduction_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_tax BOOLEAN DEFAULT FALSE,
    is_social_security BOOLEAN DEFAULT FALSE,
    is_fixed BOOLEAN DEFAULT TRUE,
    accounting_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Períodos de nómina
CREATE TABLE payroll.payroll_periods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    period_number INTEGER NOT NULL,
    period_year INTEGER NOT NULL,
    period_type VARCHAR(20) NOT NULL CHECK (period_type IN ('weekly', 'biweekly', 'monthly', 'bimonthly')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    payment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('open', 'processing', 'approved', 'paid', 'closed')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, period_number, period_year, period_type),
    CHECK (start_date <= end_date),
    CHECK (end_date <= payment_date)
);

-- Procesamiento de nómina
CREATE TABLE payroll.payroll_runs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    period_id UUID REFERENCES payroll.payroll_periods(id),
    run_number INTEGER NOT NULL,
    run_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'processing', 'completed', 'approved', 'cancelled')),
    processed_by UUID REFERENCES core.users(id),
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, period_id, run_number)
);

-- Nómina de empleados
CREATE TABLE payroll.employee_payrolls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    run_id UUID REFERENCES payroll.payroll_runs(id) ON DELETE CASCADE,
    employee_id UUID REFERENCES payroll.employees(id),
    period_id UUID REFERENCES payroll.payroll_periods(id),
    base_salary DECIMAL(19, 4) NOT NULL,
    worked_days DECIMAL(5, 2) NOT NULL,
    regular_hours DECIMAL(5, 2) NOT NULL,
    overtime_hours DECIMAL(5, 2) DEFAULT 0,
    night_hours DECIMAL(5, 2) DEFAULT 0,
    holiday_hours DECIMAL(5, 2) DEFAULT 0,
    absence_days DECIMAL(5, 2) DEFAULT 0,
    gross_income DECIMAL(19, 4) NOT NULL,
    taxable_income DECIMAL(19, 4) NOT NULL,
    tax_amount DECIMAL(19, 4) NOT NULL,
    social_security_amount DECIMAL(19, 4) NOT NULL,
    other_deductions DECIMAL(19, 4) NOT NULL,
    total_deductions DECIMAL(19, 4) NOT NULL,
    net_pay DECIMAL(19, 4) NOT NULL,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('bank_transfer', 'check', 'cash')),
    bank_account VARCHAR(50),
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'approved', 'paid', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Detalles de ingresos en nómina
CREATE TABLE payroll.payroll_income_details (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payroll_id UUID REFERENCES payroll.employee_payrolls(id) ON DELETE CASCADE,
    income_type_id UUID REFERENCES payroll.income_types(id),
    description VARCHAR(100) NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    is_taxable BOOLEAN DEFAULT TRUE,
    affects_social_security BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Detalles de deducciones en nómina
CREATE TABLE payroll.payroll_deduction_details (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payroll_id UUID REFERENCES payroll.employee_payrolls(id) ON DELETE CASCADE,
    deduction_type_id UUID REFERENCES payroll.deduction_types(id),
    description VARCHAR(100) NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Configuración de prestaciones sociales
CREATE TABLE payroll.social_benefits_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    benefit_type VARCHAR(50) NOT NULL,
    calculation_method VARCHAR(50) NOT NULL,
    rate DECIMAL(5, 2) NOT NULL,
    employer_contribution DECIMAL(5, 2) NOT NULL,
    employee_contribution DECIMAL(5, 2) NOT NULL,
    max_base_salary DECIMAL(19, 4),
    min_base_salary DECIMAL(19, 4),
    accounting_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    is_active BOOLEAN DEFAULT TRUE,
    effective_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, benefit_type, effective_date)
);

-- Prestaciones sociales de empleados
CREATE TABLE payroll.employee_social_benefits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    benefit_type VARCHAR(50) NOT NULL,
    period_id UUID REFERENCES payroll.payroll_periods(id),
    calculation_base DECIMAL(19, 4) NOT NULL,
    employee_amount DECIMAL(19, 4) NOT NULL,
    employer_amount DECIMAL(19, 4) NOT NULL,
    total_amount DECIMAL(19, 4) NOT NULL,
    payment_date DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('calculated', 'approved', 'paid', 'cancelled')),
    journal_entry_id UUID REFERENCES accounting.journal_entries(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Configuración de impuestos
CREATE TABLE payroll.tax_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    tax_type VARCHAR(50) NOT NULL,
    min_amount DECIMAL(19, 4) NOT NULL,
    max_amount DECIMAL(19, 4),
    rate DECIMAL(5, 2) NOT NULL,
    fixed_amount DECIMAL(19, 4) DEFAULT 0,
    accounting_account_id UUID REFERENCES accounting.chart_of_accounts(id),
    is_active BOOLEAN DEFAULT TRUE,
    effective_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Préstamos a empleados
CREATE TABLE payroll.employee_loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    loan_number VARCHAR(20) NOT NULL,
    loan_date DATE NOT NULL,
    loan_type VARCHAR(50) NOT NULL,
    amount DECIMAL(19, 4) NOT NULL,
    interest_rate DECIMAL(5, 2) DEFAULT 0,
    number_of_payments INTEGER NOT NULL,
    payment_frequency VARCHAR(20) NOT NULL CHECK (payment_frequency IN ('weekly', 'biweekly', 'monthly')),
    payment_amount DECIMAL(19, 4) NOT NULL,
    first_payment_date DATE NOT NULL,
    remaining_balance DECIMAL(19, 4) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'paid', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Pagos de préstamos
CREATE TABLE payroll.loan_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID REFERENCES payroll.employee_loans(id) ON DELETE CASCADE,
    payroll_id UUID REFERENCES payroll.employee_payrolls(id),
    payment_date DATE NOT NULL,
    payment_number INTEGER NOT NULL,
    principal_amount DECIMAL(19, 4) NOT NULL,
    interest_amount DECIMAL(19, 4) NOT NULL,
    total_amount DECIMAL(19, 4) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('scheduled', 'paid', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(loan_id, payment_number)
);

-- Evaluaciones de desempeño
CREATE TABLE payroll.performance_evaluations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    evaluator_id UUID REFERENCES payroll.employees(id),
    evaluation_period_start DATE NOT NULL,
    evaluation_period_end DATE NOT NULL,
    evaluation_date DATE NOT NULL,
    evaluation_type VARCHAR(50) NOT NULL,
    overall_rating DECIMAL(3, 2) NOT NULL,
    strengths TEXT,
    areas_for_improvement TEXT,
    goals TEXT,
    employee_comments TEXT,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'in_progress', 'completed', 'acknowledged')),
    acknowledged_by_employee BOOLEAN DEFAULT FALSE,
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (evaluation_period_start <= evaluation_period_end),
    CHECK (evaluation_period_end <= evaluation_date)
);

-- Criterios de evaluación
CREATE TABLE payroll.evaluation_criteria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    weight DECIMAL(5, 2) DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, name)
);

-- Detalles de evaluación
CREATE TABLE payroll.evaluation_details (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    evaluation_id UUID REFERENCES payroll.performance_evaluations(id) ON DELETE CASCADE,
    criteria_id UUID REFERENCES payroll.evaluation_criteria(id),
    rating DECIMAL(3, 2) NOT NULL,
    comments TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Capacitaciones
CREATE TABLE payroll.training_courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    provider VARCHAR(100),
    duration_hours DECIMAL(5, 2),
    cost DECIMAL(19, 4),
    is_internal BOOLEAN DEFAULT TRUE,
    is_mandatory BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, code)
);

-- Sesiones de capacitación
CREATE TABLE payroll.training_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES payroll.training_courses(id) ON DELETE CASCADE,
    session_code VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    location VARCHAR(100),
    instructor VARCHAR(100),
    max_participants INTEGER,
    status VARCHAR(20) NOT NULL CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (start_date <= end_date)
);

-- Participantes de capacitación
CREATE TABLE payroll.training_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES payroll.training_sessions(id) ON DELETE CASCADE,
    employee_id UUID REFERENCES payroll.employees(id),
    registration_date DATE NOT NULL,
    attendance_status VARCHAR(20) CHECK (attendance_status IN ('registered', 'attended', 'partially_attended', 'absent', 'cancelled')),
    completion_status VARCHAR(20) CHECK (completion_status IN ('pending', 'completed', 'failed', 'in_progress')),
    score DECIMAL(5, 2),
    certificate_issued BOOLEAN DEFAULT FALSE,
    certificate_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Reclutamiento - Vacantes
CREATE TABLE payroll.job_vacancies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    position_id UUID REFERENCES payroll.positions(id),
    department_id UUID REFERENCES payroll.departments(id),
    vacancy_code VARCHAR(20) NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    requirements TEXT,
    responsibilities TEXT,
    location VARCHAR(100),
    employment_type VARCHAR(20) NOT NULL CHECK (employment_type IN ('full_time', 'part_time', 'temporary', 'contractor')),
    min_salary DECIMAL(19, 4),
    max_salary DECIMAL(19, 4),
    is_salary_visible BOOLEAN DEFAULT FALSE,
    opening_date DATE NOT NULL,
    closing_date DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'open', 'in_progress', 'filled', 'cancelled')),
    number_of_positions INTEGER DEFAULT 1,
    hiring_manager_id UUID REFERENCES payroll.employees(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, vacancy_code)
);

-- Candidatos
CREATE TABLE payroll.candidates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    current_position VARCHAR(100),
    current_company VARCHAR(100),
    expected_salary DECIMAL(19, 4),
    availability_date DATE,
    source VARCHAR(50),
    resume_url TEXT,
    cover_letter_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, email)
);

-- Aplicaciones a vacantes
CREATE TABLE payroll.job_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vacancy_id UUID REFERENCES payroll.job_vacancies(id) ON DELETE CASCADE,
    candidate_id UUID REFERENCES payroll.candidates(id),
    application_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('received', 'under_review', 'interview', 'offer', 'hired', 'rejected', 'withdrawn')),
    current_stage VARCHAR(50),
    rejection_reason TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Entrevistas
CREATE TABLE payroll.interviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID REFERENCES payroll.job_applications(id) ON DELETE CASCADE,
    interview_type VARCHAR(50) NOT NULL,
    interview_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location VARCHAR(100),
    interviewer_id UUID REFERENCES payroll.employees(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('scheduled', 'completed', 'cancelled', 'rescheduled')),
    feedback TEXT,
    rating DECIMAL(3, 2),
    recommendation VARCHAR(20) CHECK (recommendation IN ('hire', 'reject', 'consider', 'next_round')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Ofertas de trabajo
CREATE TABLE payroll.job_offers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID REFERENCES payroll.job_applications(id) ON DELETE CASCADE,
    offer_date DATE NOT NULL,
    position_title VARCHAR(100) NOT NULL,
    department_id UUID REFERENCES payroll.departments(id),
    offered_salary DECIMAL(19, 4) NOT NULL,
    start_date DATE,
    expiration_date DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'sent', 'accepted', 'rejected', 'expired', 'withdrawn')),
    response_date DATE,
    rejection_reason TEXT,
    offer_letter_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Salud ocupacional - Incidentes
CREATE TABLE payroll.incidents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES core.companies(id) ON DELETE CASCADE,
    incident_number VARCHAR(20) NOT NULL,
    incident_date TIMESTAMP WITH TIME ZONE NOT NULL,
    incident_type VARCHAR(50) NOT NULL,
    location VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('minor', 'moderate', 'serious', 'critical', 'fatal')),
    reported_by UUID REFERENCES payroll.employees(id),
    reported_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('reported', 'investigating', 'resolved', 'closed')),
    resolution TEXT,
    resolution_date TIMESTAMP WITH TIME ZONE,
    is_reportable BOOLEAN DEFAULT FALSE,
    report_submitted_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, incident_number)
);

-- Personas involucradas en incidentes
CREATE TABLE payroll.incident_persons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    incident_id UUID REFERENCES payroll.incidents(id) ON DELETE CASCADE,
    employee_id UUID REFERENCES payroll.employees(id),
    person_type VARCHAR(20) NOT NULL CHECK (person_type IN ('employee', 'contractor', 'visitor', 'customer', 'other')),
    person_name VARCHAR(100),
    involvement_type VARCHAR(50) NOT NULL CHECK (involvement_type IN ('injured', 'witness', 'first_responder', 'supervisor', 'investigator')),
    injury_description TEXT,
    treatment_provided TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Exámenes médicos
CREATE TABLE payroll.medical_examinations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES payroll.employees(id) ON DELETE CASCADE,
    examination_type VARCHAR(50) NOT NULL,
    examination_date DATE NOT NULL,
    provider VARCHAR(100),
    result VARCHAR(20) NOT NULL CHECK (result IN ('normal', 'abnormal', 'pending')),
    observations TEXT,
    recommendations TEXT,
    next_examination_date DATE,
    document_url TEXT,
    is_confidential BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos iniciales

-- Departamentos
INSERT INTO payroll.departments (company_id, code, name, cost_center_id)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ADM', 'Administración', 
     (SELECT id FROM accounting.cost_centers WHERE code = 'ADM')),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'VEN', 'Ventas', 
     (SELECT id FROM accounting.cost_centers WHERE code = 'VEN')),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PRO', 'Producción', 
     (SELECT id FROM accounting.cost_centers WHERE code = 'PRO')),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'FIN', 'Finanzas', 
     (SELECT id FROM accounting.cost_centers WHERE code = 'FIN')),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RH', 'Recursos Humanos', 
     (SELECT id FROM accounting.cost_centers WHERE code = 'ADM')),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'TI', 'Tecnología de la Información', 
     (SELECT id FROM accounting.cost_centers WHERE code = 'ADM'));

-- Cargos
INSERT INTO payroll.positions (company_id, code, name, department_id, min_salary, max_salary)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'GG', 'Gerente General', 
     (SELECT id FROM payroll.departments WHERE code = 'ADM'), 5000000, 8000000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'GV', 'Gerente de Ventas', 
     (SELECT id FROM payroll.departments WHERE code = 'VEN'), 4000000, 6000000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'GP', 'Gerente de Producción', 
     (SELECT id FROM payroll.departments WHERE code = 'PRO'), 4000000, 6000000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'GF', 'Gerente Financiero', 
     (SELECT id FROM payroll.departments WHERE code = 'FIN'), 4000000, 6000000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'GRH', 'Gerente de Recursos Humanos', 
     (SELECT id FROM payroll.departments WHERE code = 'RH'), 4000000, 6000000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'GTI', 'Gerente de TI', 
     (SELECT id FROM payroll.departments WHERE code = 'TI'), 4000000, 6000000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'VEN', 'Vendedor', 
     (SELECT id FROM payroll.departments WHERE code = 'VEN'), 1500000, 2500000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'OPE', 'Operario', 
     (SELECT id FROM payroll.departments WHERE code = 'PRO'), 1200000, 1800000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CON', 'Contador', 
     (SELECT id FROM payroll.departments WHERE code = 'FIN'), 2000000, 3000000),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ASI', 'Asistente Administrativo', 
     (SELECT id FROM payroll.departments WHERE code = 'ADM'), 1200000, 1800000);

-- Tipos de ausencia
INSERT INTO payroll.absence_types (company_id, code, name, description, is_paid, affects_payroll, max_days_per_year, requires_approval, requires_documentation)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'VAC', 'Vacaciones', 'Vacaciones anuales', TRUE, TRUE, 15, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ENF', 'Enfermedad', 'Ausencia por enfermedad', TRUE, TRUE, NULL, TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PER', 'Permiso Personal', 'Permiso por asuntos personales', TRUE, TRUE, 3, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'MAT', 'Licencia de Maternidad', 'Licencia por maternidad', TRUE, TRUE, NULL, TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PAT', 'Licencia de Paternidad', 'Licencia por paternidad', TRUE, TRUE, NULL, TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CAP', 'Capacitación', 'Ausencia por capacitación', TRUE, FALSE, NULL, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'LUT', 'Luto', 'Licencia por luto', TRUE, TRUE, 5, TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'INJ', 'Injustificada', 'Ausencia injustificada', FALSE, TRUE, NULL, FALSE, FALSE);

-- Horarios de trabajo
INSERT INTO payroll.work_schedules (company_id, code, name, description, is_default)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'EST', 'Estándar', 'Horario estándar de lunes a viernes', TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'TUR', 'Turnos', 'Horario por turnos', FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'FLX', 'Flexible', 'Horario flexible', FALSE);

-- Detalles de horario estándar
INSERT INTO payroll.work_schedule_details (schedule_id, day_of_week, is_workday, start_time, end_time, break_start_time, break_end_time, total_hours)
VALUES 
    ((SELECT id FROM payroll.work_schedules WHERE code = 'EST'), 1, TRUE, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 8),
    ((SELECT id FROM payroll.work_schedules WHERE code = 'EST'), 2, TRUE, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 8),
    ((SELECT id FROM payroll.work_schedules WHERE code = 'EST'), 3, TRUE, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 8),
    ((SELECT id FROM payroll.work_schedules WHERE code = 'EST'), 4, TRUE, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 8),
    ((SELECT id FROM payroll.work_schedules WHERE code = 'EST'), 5, TRUE, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 8),
    ((SELECT id FROM payroll.work_schedules WHERE code = 'EST'), 6, FALSE, NULL, NULL, NULL, NULL, 0),
    ((SELECT id FROM payroll.work_schedules WHERE code = 'EST'), 7, FALSE, NULL, NULL, NULL, NULL, 0);

-- Tipos de ingresos
INSERT INTO payroll.income_types (company_id, code, name, description, is_taxable, affects_social_security, is_fixed)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SAL', 'Salario Básico', 'Salario base mensual', TRUE, TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'HE', 'Horas Extras', 'Pago por horas extras', TRUE, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'BON', 'Bonificación', 'Bonificación por desempeño', TRUE, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'COM', 'Comisiones', 'Comisiones por ventas', TRUE, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'VAC', 'Vacaciones', 'Pago de vacaciones', TRUE, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PRI', 'Prima Legal', 'Prima legal semestral', TRUE, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CES', 'Cesantías', 'Pago de cesantías', TRUE, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'INT', 'Intereses Cesantías', 'Intereses sobre cesantías', TRUE, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'AUX', 'Auxilio de Transporte', 'Auxilio de transporte', TRUE, TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'VIA', 'Viáticos', 'Viáticos no gravados', FALSE, FALSE, FALSE);

-- Tipos de deducciones
INSERT INTO payroll.deduction_types (company_id, code, name, description, is_tax, is_social_security, is_fixed)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SAL', 'Salud', 'Aporte a salud', FALSE, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PEN', 'Pensión', 'Aporte a pensión', FALSE, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RET', 'Retención en la Fuente', 'Retención en la fuente', TRUE, FALSE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PRE', 'Préstamo', 'Cuota de préstamo', FALSE, FALSE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'AFC', 'Ahorro AFC', 'Ahorro para el fomento de la construcción', FALSE, FALSE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'FPV', 'Fondo Pensión Voluntaria', 'Aporte a fondo de pensión voluntaria', FALSE, FALSE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'EMB', 'Embargo', 'Embargo judicial', FALSE, FALSE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SIN', 'Sindicato', 'Cuota sindical', FALSE, FALSE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SEG', 'Seguro', 'Seguro colectivo', FALSE, FALSE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'OTR', 'Otros Descuentos', 'Otros descuentos', FALSE, FALSE, FALSE);

-- Configuración de prestaciones sociales
INSERT INTO payroll.social_benefits_config (company_id, benefit_type, calculation_method, rate, employer_contribution, employee_contribution, effective_date)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SALUD', 'PORCENTAJE', 12.5, 8.5, 4.0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PENSION', 'PORCENTAJE', 16.0, 12.0, 4.0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ARL', 'PORCENTAJE', 0.522, 0.522, 0.0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CAJA', 'PORCENTAJE', 4.0, 4.0, 0.0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ICBF', 'PORCENTAJE', 3.0, 3.0, 0.0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SENA', 'PORCENTAJE', 2.0, 2.0, 0.0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'CESANTIAS', 'PORCENTAJE', 8.33, 8.33, 0.0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'INTERESES', 'PORCENTAJE', 1.0, 1.0, 0.0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'PRIMA', 'PORCENTAJE', 8.33, 8.33, 0.0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'VACACIONES', 'PORCENTAJE', 4.17, 4.17, 0.0, '2025-01-01');

-- Configuración de impuestos
INSERT INTO payroll.tax_config (company_id, tax_type, min_amount, max_amount, rate, fixed_amount, effective_date)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RETENCION', 0, 2300000, 0, 0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RETENCION', 2300001, 3600000, 19, 0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RETENCION', 3600001, 7900000, 28, 0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RETENCION', 7900001, 16400000, 33, 0, '2025-01-01'),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RETENCION', 16400001, 999999999999, 35, 0, '2025-01-01');

-- Criterios de evaluación
INSERT INTO payroll.evaluation_criteria (company_id, name, description, category, weight)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Calidad del Trabajo', 'Precisión, minuciosidad y consistencia en las tareas', 'DESEMPEÑO', 1.0),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Productividad', 'Cantidad de trabajo completado en un período determinado', 'DESEMPEÑO', 1.0),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Conocimiento del Trabajo', 'Comprensión de las tareas, procedimientos y técnicas del puesto', 'CONOCIMIENTO', 1.0),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Iniciativa', 'Capacidad para actuar independientemente y proponer mejoras', 'ACTITUD', 1.0),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Trabajo en Equipo', 'Capacidad para trabajar eficazmente con otros', 'INTERPERSONAL', 1.0),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Comunicación', 'Habilidad para comunicarse clara y efectivamente', 'INTERPERSONAL', 1.0),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Resolución de Problemas', 'Capacidad para identificar y resolver problemas', 'HABILIDAD', 1.0),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Liderazgo', 'Capacidad para guiar y motivar a otros', 'LIDERAZGO', 1.0),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Adaptabilidad', 'Capacidad para adaptarse a cambios y nuevas situaciones', 'ACTITUD', 1.0),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'Puntualidad y Asistencia', 'Cumplimiento con horarios y asistencia', 'DISCIPLINA', 1.0);

-- Cursos de capacitación
INSERT INTO payroll.training_courses (company_id, code, name, description, duration_hours, is_internal, is_mandatory)
VALUES 
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'IND', 'Inducción Corporativa', 'Curso de inducción para nuevos empleados', 8, TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'SEG', 'Seguridad y Salud en el Trabajo', 'Capacitación en seguridad laboral', 4, TRUE, TRUE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'LID', 'Liderazgo Efectivo', 'Desarrollo de habilidades de liderazgo', 16, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'VEN', 'Técnicas de Venta', 'Estrategias y técnicas de venta efectivas', 12, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'EXC', 'Excel Avanzado', 'Uso avanzado de Microsoft Excel', 20, FALSE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'COM', 'Comunicación Efectiva', 'Habilidades de comunicación en el entorno laboral', 8, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'ATN', 'Atención al Cliente', 'Técnicas de atención y servicio al cliente', 8, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'GES', 'Gestión del Tiempo', 'Estrategias para la gestión eficiente del tiempo', 4, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'TRA', 'Trabajo en Equipo', 'Desarrollo de habilidades para el trabajo en equipo', 8, TRUE, FALSE),
    ((SELECT id FROM core.companies WHERE name = 'Empresa Demo'), 'RES', 'Resolución de Conflictos', 'Técnicas para la resolución efectiva de conflictos', 8, TRUE, FALSE);

