import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuditLog } from '../entities/audit-log.entity';

export interface AuditLogPayload {
  userId?: string | null;
  entityType: string;
  entityId: string;
  action: string;
  previousState?: any;
  newState?: any;
  ipAddress?: string | null;
  userAgent?: string | null;
}

@Injectable()
export class AuditService {
  constructor(
    @InjectRepository(AuditLog)
    private readonly repo: Repository<AuditLog>,
  ) {}

  async log(payload: AuditLogPayload): Promise<void> {
    const log = this.repo.create({
      userId: payload.userId ?? null,
      entityType: payload.entityType,
      entityId: payload.entityId,
      action: payload.action,
      previousState: payload.previousState ?? null,
      newState: payload.newState ?? null,
      ipAddress: payload.ipAddress ?? null,
      userAgent: payload.userAgent ?? null,
    });
    await this.repo.save(log);
  }
}
