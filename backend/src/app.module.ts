import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import configuration from './config/configuration';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { I18nModule, I18nJsonParser, QueryResolver, AcceptLanguageResolver } from '@nestjs/i18n';
import { join } from 'path';

import { HelloController } from './hello.controller';

// Interceptor
import { AuditInterceptor } from './common/interceptors/audit.interceptor';

// Módulos principales
// Importamos solo el CoreModule por ahora
import { CoreModule } from './modules/core/core.module';
import { UsersModule } from './modules/users/users.module';
import { AuthModule } from './modules/auth/auth.module';
import { AuditModule } from './modules/audit/audit.module';
import { InventoryModule } from './modules/inventory/inventory.module';
import { SalesModule } from './modules/sales/sales.module';

@Module({
  imports: [
    // Configuración global y carga de variables desde .env
    ConfigModule.forRoot({ isGlobal: true, load: [configuration] }),

    I18nModule.forRoot({
      fallbackLanguage: 'en',
      parser: I18nJsonParser,
      parserOptions: {
        path: join(__dirname, '/i18n/'),
        watch: false,
      },
      resolvers: [
        { use: QueryResolver, options: ['lang'] },
        AcceptLanguageResolver,
      ],
    }),

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
    AuthModule,
    AuditModule,
    InventoryModule,
    SalesModule,
  ],
  controllers: [HelloController],
  providers: [
    {
      provide: APP_INTERCEPTOR,
      useClass: AuditInterceptor,
    },
  ],
})
export class AppModule {}