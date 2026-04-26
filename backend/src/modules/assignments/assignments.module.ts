import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { AssignmentService } from './application/assignment.service';
import { AssignmentsInteractionService } from './application/assignments-interaction.service';
import { OverdueCheckerService } from './application/overdue-checker.service';
import { AssignmentController } from './presentation/assignment.controller';
import { AssigmentInterationController } from './presentation/assigment-interation.controller';
import { NotificationAssignmentRepository } from './infrastructure/assignment.repository.impl';
import { NotificationRepository } from '../notifications/infrastructure/notification.repository.impl';

@Module({
  imports: [ScheduleModule.forRoot()],
  providers: [
    AssignmentService,
    AssignmentsInteractionService,
    OverdueCheckerService,
    NotificationAssignmentRepository,
    NotificationRepository,
  ],
  controllers: [AssigmentInterationController, AssignmentController],
  exports: [AssignmentService, NotificationAssignmentRepository],
})
export class AssignmentsModule {}
