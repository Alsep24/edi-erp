import { NestFactory, Reflector } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe, VersioningType, Logger } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import * as cookieParser from 'cookie-parser';

const logger = new Logger('Bootstrap');

function validateEnv() {
  const required = ['JWT_SECRET', 'DB_HOST', 'DB_USERNAME', 'DB_PASSWORD', 'DB_NAME'];
  const missing = required.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    logger.warn(
      `Variables de entorno no configuradas (usando valores por defecto): ${missing.join(', ')}`,
    );
    if (process.env.NODE_ENV === 'production') {
      throw new Error(`Variables requeridas en producción: ${missing.join(', ')}`);
    }
  }
  if (process.env.JWT_SECRET === 'secretKey') {
    logger.warn('JWT_SECRET está usando el valor por defecto. Cambiarlo en producción.');
  }
}

async function bootstrap() {
  validateEnv();

  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log', 'verbose'],
    bufferLogs: true,
  });

  app.setGlobalPrefix('api');
  app.enableVersioning({ type: VersioningType.URI });

  // Cookie parser (para refresh token en HTTP-only cookie)
  app.use(cookieParser());

  // Filtros y pipes globales
  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // CORS
  app.enableCors({
    origin: process.env.CORS_ORIGIN || 'http://localhost:8080',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept-Language'],
    credentials: true,
  });

  // Swagger / OpenAPI
  const config = new DocumentBuilder()
    .setTitle('EDI-ERP API')
    .setDescription(
      'API REST para el sistema ERP modular EDI. Gestión de empresas, usuarios, inventario, ventas y más.',
    )
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('auth', 'Autenticación y gestión de sesión')
    .addTag('users', 'Gestión de usuarios')
    .addTag('roles', 'Roles y permisos')
    .addTag('companies', 'Empresas y sucursales')
    .addTag('products', 'Productos e inventario')
    .addTag('customers', 'Clientes')
    .addTag('invoices', 'Facturas de venta')
    .addTag('purchases', 'Órdenes de compra')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: { persistAuthorization: true },
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);
  logger.log(`Aplicación iniciada en: http://localhost:${port}/api`);
  logger.log(`Documentación Swagger en: http://localhost:${port}/api/docs`);
}
bootstrap();
