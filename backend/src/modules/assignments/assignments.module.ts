import { Module } from '@nestjs/common';
import { AssignmentService } from './application/assignment.service';
import { AssignmentsInteractionService } from './application/assignments-interaction.service';
import { AssignmentController } from './presentation/assignment.controller';
import { AssigmentInterationController } from './presentation/assigment-interation.controller';
import { NotificationAssignmentRepository } from './infrastructure/assignment.repository.impl';
import { NotificationRepository } from '../notifications/infrastructure/notification.repository.impl';

@Module({
  providers: [
    AssignmentService,
    AssignmentsInteractionService,
    NotificationAssignmentRepository,
    NotificationRepository,
  ],
  controllers: [AssignmentController, AssigmentInterationController],
})
export class AssignmentsModule {}
