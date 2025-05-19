export default () => ({
  // Configuración general
  port: parseInt(process.env.PORT, 10) || 3000,
  environment: process.env.NODE_ENV || 'development',
  
  // Configuración de base de datos
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 5432,
    username: process.env.DB_USERNAME || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    name: process.env.DB_NAME || 'edi_erp',
    synchronize: process.env.DB_SYNCHRONIZE === 'true',
    logging: process.env.DB_LOGGING === 'true',
    ssl: process.env.DB_SSL === 'true',
  },
  
  // Configuración de JWT
  jwt: {
    secret: process.env.JWT_SECRET || 'secretKey',
    expiresIn: process.env.JWT_EXPIRES_IN || '1d',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },
  
  // Configuración de CORS
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
  },
  
  // Configuración de throttle (limitación de peticiones)
  throttle: {
    ttl: parseInt(process.env.THROTTLE_TTL, 10) || 60,
    limit: parseInt(process.env.THROTTLE_LIMIT, 10) || 10,
  },
  
  // Configuración de correo electrónico
  mail: {
    host: process.env.MAIL_HOST || 'smtp.example.com',
    port: parseInt(process.env.MAIL_PORT, 10) || 587,
    secure: process.env.MAIL_SECURE === 'true',
    user: process.env.MAIL_USER || 'user@example.com',
    password: process.env.MAIL_PASSWORD || 'password',
    from: process.env.MAIL_FROM || 'ERP EDI <noreply@example.com>',
  },
  
  // Configuración de almacenamiento de archivos
  storage: {
    type: process.env.STORAGE_TYPE || 'local',
    local: {
      path: process.env.STORAGE_LOCAL_PATH || './uploads',
    },
    s3: {
      bucket: process.env.STORAGE_S3_BUCKET || 'edi-erp',
      region: process.env.STORAGE_S3_REGION || 'us-east-1',
      accessKey: process.env.STORAGE_S3_ACCESS_KEY || '',
      secretKey: process.env.STORAGE_S3_SECRET_KEY || '',
    },
  },
  
  // Configuración de logging
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    file: process.env.LOG_FILE || 'logs/app.log',
  },
});
