import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Configuración global de validación de datos
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    transform: true,
  }));
  
  // Prefijo global para todas las rutas API
  app.setGlobalPrefix('api');
  
  // Configuración de CORS
  app.enableCors();
  
  await app.listen(3000);
  console.log(`Aplicación iniciada en: http://localhost:3000/api`);
}
bootstrap();
