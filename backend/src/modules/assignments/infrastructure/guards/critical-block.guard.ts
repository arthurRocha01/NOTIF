import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../../../auth/infrastructure/decorators/public.decorator';
import { BYPASS_BLOCK_KEY } from '../decorators/bypass-block.decorator';
import { NotificationAssignmentRepository } from '../assignment.repository.impl';
import { AssignmentResponseDto } from '../../dto/assignment-response.dto';

@Injectable()
export class CriticalBlockGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly assignmentRepo: NotificationAssignmentRepository,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const bypassBlock = this.reflector.getAllAndOverride<boolean>(
      BYPASS_BLOCK_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (bypassBlock) return true;

    const request = context.switchToHttp().getRequest();
    const userId = request.user?.userId;
    if (!userId) return true;

    if (request.user?.role === 'ADMIN') return true;

    const blocking = await this.assignmentRepo.findBlockingByUserId(userId);
    if (blocking.length === 0) return true;

    throw new ForbiddenException({
      message:
        'Você possui notificações críticas que precisam de confirmação',
      blockingAssignments: blocking.map(AssignmentResponseDto.fromDomain),
    });
  }
}
