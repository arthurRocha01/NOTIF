import { Controller, Get } from '@nestjs/common';
import { NotificationService } from '../application/notification.service';

@Controller('notifications')
export class NotificationController {
  constructor(private readonly service: NotificationService) {}

  @Get()
  getAllUsers() {
    return this.service.getAllUsers();
  }
}
