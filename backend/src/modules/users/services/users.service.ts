import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { CreateUserDto } from '../dto/create-user.dto';
import { UpdateUserDto } from '../dto/update-user.dto';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
    private readonly configService: ConfigService,
  ) {}

  private get saltRounds(): number {
    const rounds = parseInt(this.configService.get<string>('BCRYPT_SALT_ROUNDS') ?? '10', 10);
    return Number.isNaN(rounds) ? 10 : rounds;
  }

  async create(dto: CreateUserDto): Promise<User> {
    const passwordHash = await bcrypt.hash(dto.password, this.saltRounds);
    const user = this.usersRepository.create({
      username: dto.username,
      email: dto.email,
      passwordHash,
      firstName: dto.firstName,
      lastName: dto.lastName,
      isAdmin: dto.isAdmin ?? false,
    });
    const saved = await this.usersRepository.save(user);
    this.logger.log(`Usuario creado: ${saved.username} (${saved.id})`);
    return saved;
  }

  findAll(): Promise<User[]> {
    return this.usersRepository.find({ relations: ['roles'], order: { username: 'ASC' } });
  }

  findOne(id: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { id } });
  }

  /** Carga el usuario con sus roles para la autenticación */
  findOneWithRoles(id: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { id }, relations: ['roles', 'roles.permissions'] });
  }

  findByUsername(username: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { username } });
  }

  async update(id: string, dto: UpdateUserDto): Promise<User> {
    const existing = await this.findOne(id);
    if (!existing) throw new NotFoundException(`User #${id} not found`);

    if (dto.password) {
      const passwordHash = await bcrypt.hash(dto.password, this.saltRounds);
      await this.usersRepository.update(id, { ...dto, passwordHash } as any);
    } else {
      await this.usersRepository.update(id, dto as any);
    }
    return this.findOne(id);
  }

  async remove(id: string): Promise<User> {
    const user = await this.findOne(id);
    if (!user) throw new NotFoundException(`User #${id} not found`);
    await this.usersRepository.delete(id);
    this.logger.log(`Usuario eliminado: ${user.username} (${id})`);
    return user;
  }

  async changePassword(id: string, newPassword: string): Promise<void> {
    const passwordHash = await bcrypt.hash(newPassword, this.saltRounds);
    await this.usersRepository.update(id, { passwordHash });
    this.logger.log(`Contraseña cambiada para usuario ${id}`);
  }
}
