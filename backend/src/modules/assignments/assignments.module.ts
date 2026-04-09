import { Module } from '@nestjs/common';
import { AssignmentService } from './application/assignment.service';
import { AssignmentController } from './presentation/assignment.controller';
import { NotificationAssignmentRepository } from './infrastructure/assignment.repository.impl';

@Module({
  providers: [AssignmentService, NotificationAssignmentRepository],
  controllers: [AssignmentController],
})
export class AssignmentsModule {}
