import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Entidades
import { Company } from './entities/company.entity';
import { Branch } from './entities/branch.entity';
import { Configuration } from './entities/configuration.entity';

// Controladores y servicios (comentados hasta que se implementen completamente)
// import { CompaniesController } from './controllers/companies.controller';
// import { BranchesController } from './controllers/branches.controller';
// import { ConfigurationsController } from './controllers/configurations.controller';
// import { CompaniesService } from './services/companies.service';
// import { BranchesService } from './services/branches.service';
// import { ConfigurationsService } from './services/configurations.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Company,
      Branch,
      Configuration,
    ]),
  ],
  controllers: [
    // CompaniesController,
    // BranchesController,
    // ConfigurationsController,
  ],
  providers: [
    // CompaniesService,
    // BranchesService,
    // ConfigurationsService,
  ],
  exports: [
    // Exportamos los servicios que serán utilizados por otros módulos
    // CompaniesService,
    // BranchesService,
    // ConfigurationsService,
  ],
})
export class CoreModule {}
