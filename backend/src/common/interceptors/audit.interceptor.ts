import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { AuditService } from '../../modules/audit/services/audit.service';

@Injectable()
export class AuditInterceptor implements NestInterceptor {
  constructor(private readonly auditService: AuditService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const method = request.method;
    const user = request.user;
    const ip = request.ip;
    const userAgent = request.headers['user-agent'];
    const entityId = request.params?.id ?? null;
    const entityType = context.getClass().name.replace('Controller', '');

    return next.handle().pipe(
      tap(async (responseData) => {
        let action: string | null = null;
        if (['POST'].includes(method)) action = 'CREATE';
        if (['PUT', 'PATCH'].includes(method)) action = 'UPDATE';
        if (method === 'DELETE') action = 'DELETE';
        if (request.route?.path === 'login' || request.url.includes('login')) action = 'LOGIN';

        if (action) {
          await this.auditService.log({
            userId: user?.id,
            entityType,
            entityId: entityId || (responseData && responseData.id),
            action,
            newState: responseData,
            ipAddress: ip,
            userAgent,
          });
        }
      }),
    );
  }
}
