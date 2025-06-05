import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { CreateUserDto } from '../dto/create-user.dto';
import { UpdateUserDto } from '../dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
    private readonly configService: ConfigService,
  ) {}

  private get saltRounds(): number {
    const rounds = parseInt(
      this.configService.get<string>('BCRYPT_SALT_ROUNDS') ?? '10',
      10,
    );
    return Number.isNaN(rounds) ? 10 : rounds;
  }

  async create(dto: CreateUserDto) {
    const passwordHash = await bcrypt.hash(dto.password, this.saltRounds);
    const user = this.usersRepository.create({
      username: dto.username,
      email: dto.email,
      passwordHash,
      firstName: dto.firstName,
      lastName: dto.lastName,
      isAdmin: dto.isAdmin ?? false,
    });
    return this.usersRepository.save(user);
  }

  findAll() {
    return this.usersRepository.find();
  }

  findOne(id: string) {
    return this.usersRepository.findOne({ where: { id } });
  }

  findByUsername(username: string) {
    return this.usersRepository.findOne({ where: { username } });
  }

  async update(id: string, dto: UpdateUserDto) {
    if (dto.password) {
      const passwordHash = await bcrypt.hash(dto.password, this.saltRounds);
      await this.usersRepository.update(id, {
        ...dto,
        passwordHash,
      });
    } else {
      await this.usersRepository.update(id, dto as any);
    }
    return this.findOne(id);
  }

  async remove(id: string) {
    const user = await this.findOne(id);
    await this.usersRepository.delete(id);
    return user;
  }
}
