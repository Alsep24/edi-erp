import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { User } from '../../users/entities/user.entity';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>('roles', [
      ctx.getHandler(),
      ctx.getClass(),
    ]);

    if (!requiredRoles || requiredRoles.length === 0) return true;

    const user: User = ctx.switchToHttp().getRequest().user;
    if (!user) return false;

    // Admin tiene acceso total
    if (user.isAdmin) return true;

    // Verificar contra roles asignados al usuario
    const userRoleNames = (user.roles ?? []).map((r) => r.name.toLowerCase());
    return requiredRoles.some((role) => userRoleNames.includes(role.toLowerCase()));
  }
}
