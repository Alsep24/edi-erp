import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../../users/services/users.service';
import { ConfigService } from '@nestjs/config';
import { LoginDto } from '../dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async validateUser(username: string, pass: string) {
    const user = await this.usersService.findByUsername(username);
    if (user && user.passwordHash === pass) {
      return user;
    }
    return null;
  }

  async login(dto: LoginDto) {
    const user = await this.validateUser(dto.username, dto.password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    const payload = { username: user.username, sub: user.id };
    const accessToken = await this.jwtService.signAsync(payload, {
      expiresIn: this.configService.get<string>('jwt.expiresIn'),
    });
    const refreshToken = await this.jwtService.signAsync(payload, {
      expiresIn: this.configService.get<string>('jwt.refreshExpiresIn'),
    });
    return { accessToken, refreshToken };
  }

  async refreshToken(token: string) {
    try {
      const payload = await this.jwtService.verifyAsync(token, {
        secret: this.configService.get<string>('jwt.secret'),
      });
      const newPayload = { username: payload.username, sub: payload.sub };
      const accessToken = await this.jwtService.signAsync(newPayload, {
        expiresIn: this.configService.get<string>('jwt.expiresIn'),
      });
      return { accessToken };
    } catch (e) {
      throw new UnauthorizedException('Invalid token');
    }
  }

  logout() {
    return { message: 'Logged out' };
  }
}
