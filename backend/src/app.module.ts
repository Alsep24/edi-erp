import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import configuration from './config/configuration';

// Módulos principales
// Importamos solo el CoreModule por ahora
import { CoreModule } from './modules/core/core.module';
import { UsersModule } from './modules/users/users.module';

@Module({
  imports: [
    // Configuración global y carga de variables desde .env
    ConfigModule.forRoot({ isGlobal: true, load: [configuration] }),

    // Configuración asíncrona de TypeORM utilizando ConfigService
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get<string>('database.host'),
        port: config.get<number>('database.port'),
        username: config.get<string>('database.username'),
        password: config.get<string>('database.password'),
        database: config.get<string>('database.name'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: config.get<boolean>('database.synchronize'),
        logging: config.get<boolean>('database.logging'),
        ssl: config.get<boolean>('database.ssl'),
      }),
    }),

    // Módulos de la aplicación
    CoreModule,
    UsersModule,
    // Los demás módulos se agregarán a medida que se implementen
  ],
  providers: [],
})
export class AppModule {}
