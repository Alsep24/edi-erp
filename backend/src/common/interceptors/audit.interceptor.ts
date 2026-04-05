import {
  Injectable, NestInterceptor, ExecutionContext, CallHandler, Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { throwError } from 'rxjs';
import { AuditService } from '../../modules/audit/services/audit.service';

@Injectable()
export class AuditInterceptor implements NestInterceptor {
  private readonly logger = new Logger(AuditInterceptor.name);

  constructor(private readonly auditService: AuditService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, ip, params, url } = request;
    const user = request.user;
    const userAgent = request.headers['user-agent'] ?? 'unknown';
    const entityId = params?.id ?? null;
    const entityType = context.getClass().name.replace('Controller', '');
    const startTime = Date.now();

    return next.handle().pipe(
      tap(async (responseData) => {
        const ms = Date.now() - startTime;
        this.logger.log(`${method} ${url} → 2xx [${ms}ms] user=${user?.id ?? 'anonymous'}`);

        let action: string | null = null;
        if (method === 'POST') action = url.includes('login') ? 'LOGIN' : 'CREATE';
        if (method === 'PUT' || method === 'PATCH') action = 'UPDATE';
        if (method === 'DELETE') action = 'DELETE';

        if (action && this.shouldAudit(url)) {
          try {
            await this.auditService.log({
              userId: user?.id,
              entityType,
              entityId: entityId || (responseData && responseData.id),
              action,
              newState: responseData,
              ipAddress: ip,
              userAgent,
            });
          } catch (err) {
            this.logger.error('Error al guardar audit log', err);
          }
        }
      }),
      catchError((error) => {
        const ms = Date.now() - startTime;
        this.logger.warn(
          `${method} ${url} → ${error.status ?? 500} [${ms}ms] ${error.message}`,
        );
        return throwError(() => error);
      }),
    );
  }

  private shouldAudit(url: string): boolean {
    // No auditar endpoints de sólo lectura ni documentación
    return !url.includes('/docs') && !url.includes('/health');
  }
}
