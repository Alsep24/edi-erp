import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe, VersioningType } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log'],
  });

  // Prefijo global para todas las rutas API
  app.setGlobalPrefix('api');

  // Versionado de API
  app.enableVersioning({ type: VersioningType.URI });

  // Filtro global de excepciones HTTP
  app.useGlobalFilters(new HttpExceptionFilter());

  // Configuración global de validación de datos
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  // Configuración de CORS
  app.enableCors({
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept-Language'],
    credentials: true,
  });

  // Documentación Swagger / OpenAPI
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
  console.log(`Aplicación iniciada en: http://localhost:${port}/api`);
  console.log(`Documentación Swagger en: http://localhost:${port}/api/docs`);
}
bootstrap();
