import { Injectable } from '@nestjs/common';
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
  ) {}

  create(dto: CreateUserDto) {
    const user = this.usersRepository.create({
      username: dto.username,
      email: dto.email,
      passwordHash: dto.password,
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

  async update(id: string, dto: UpdateUserDto) {
    if (dto.password) {
      await this.usersRepository.update(id, {
        ...dto,
        passwordHash: dto.password,
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
