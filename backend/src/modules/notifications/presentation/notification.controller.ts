import { Controller, Get } from '@nestjs/common';
import type { NotificationService } from '../application/notification.service';

@Controller('notification')
export class NotificationController {
  constructor(private readonly service: NotificationService) {}

  @Get()
  getAllUsers() {
    return this.service.getAllUsers();
  }
}
