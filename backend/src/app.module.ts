import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Módulos principales
// Importamos solo el CoreModule por ahora
import { CoreModule } from './modules/core/core.module';

@Module({
  imports: [
    // Configuración de TypeORM
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: 'localhost',
      port: 5432,
      username: 'postgres',
      password: 'postgres',
      database: 'edi_erp',
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: true, // Solo para desarrollo
    }),
    
    // Módulos de la aplicación
    CoreModule,
    // Los demás módulos se agregarán a medida que se implementen
  ],
  providers: [],
})
export class AppModule {}
