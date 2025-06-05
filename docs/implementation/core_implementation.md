# Implementación del módulo Core

Esta sección describe las entidades principales del módulo **core** y cómo se relacionan entre sí. También se muestran ejemplos de uso de los servicios y una breve explicación sobre la configuración de TypeORM.

## Relación de entidades

### Company
Representa una empresa dentro del sistema. Cada registro tiene datos básicos como `name`, `taxId` y dirección. Las sucursales y las configuraciones pueden asociarse a una empresa.

### Branch
Una *Branch* está vinculada a una empresa mediante una relación `ManyToOne`. En el modelo se define:

```ts
@ManyToOne(() => Company)
@JoinColumn({ name: 'company_id' })
company: Company;
```

Esto significa que cada sucursal pertenece a una empresa. Una empresa puede tener varias sucursales.

### Configuration
Las configuraciones guardan pares clave/valor que pueden ser globales o específicas de una empresa. La entidad contiene un campo `company` opcional:

```ts
@ManyToOne(() => Company, { nullable: true })
@JoinColumn({ name: 'company_id' })
company: Company;
```

Si `company` es `null` la configuración se considera global para todo el sistema.

## Ejemplos de uso de servicios

Los servicios ofrecen métodos básicos para manipular cada entidad. Algunos ejemplos ilustrativos:

```ts
// Crear una sucursal asociada a una empresa
const dto = new CreateBranchDto();
dto.name = 'Sucursal Centro';
dto.address = 'Av. Principal';
// id de la empresa previamente creada
branchesService.create(dto);

// Obtener todas las sucursales de una empresa
branchesService.findByCompany(companyId);

// Buscar una configuración por clave, pudiendo filtrar por empresa
configurationsService.findByKey('theme', companyId);
```

Los servicios de `companies`, `branches` y `configurations` siguen la misma estructura con los métodos `create`, `findAll`, `findOne`, `update` y `remove`.

## Configuración de TypeORM

El archivo `app.module.ts` configura la conexión a la base de datos utilizando `TypeOrmModule.forRootAsync`. Las variables se leen desde el `ConfigService`:

```ts
TypeOrmModule.forRootAsync({
  useFactory: (config: ConfigService) => ({
    type: 'postgres',
    host: config.get('database.host'),
    port: config.get('database.port'),
    username: config.get('database.username'),
    password: config.get('database.password'),
    database: config.get('database.name'),
    entities: [__dirname + '/**/*.entity{.ts,.js}'],
    synchronize: config.get('database.synchronize'),
    logging: config.get('database.logging'),
    ssl: config.get('database.ssl'),
  }),
})
```

Todas las entidades dentro de `src/**/entities` se cargan automáticamente gracias al patrón de ruta `/**/*.entity{.ts,.js}`.

### Extender el módulo con nuevas entidades

Para agregar nuevas entidades al módulo **core** se debe:

1. Crear la clase entidad en `src/modules/core/entities`.
2. Importarla en `core.module.ts` dentro de `TypeOrmModule.forFeature([...])`.
3. Incluir el servicio y controlador correspondiente en los arreglos `providers` y `controllers` del `CoreModule` (actualmente comentados).

De esta forma el repositorio de TypeORM quedará disponible para inyección en los servicios.
