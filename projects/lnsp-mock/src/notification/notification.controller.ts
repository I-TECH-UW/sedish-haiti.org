// src/notification/notification.controller.ts
import { Controller, Post, Req, Res, HttpStatus, Body} from '@nestjs/common';
import { Request, Response} from 'express';
import { NotificationService } from './notification.service';

@Controller('notify')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post()
  async handleNotification(@Body() body: string, @Res() res: Response) {
    let soapMessage = body;

    try {
      const documentId = await this.notificationService.extractDocumentId(soapMessage);
      const hl7Message = await this.notificationService.retrieveORMMessage(documentId);
      const parsedHL7 = this.notificationService.parseORMMessage(hl7Message);
      const resultHL7 = this.notificationService.generateORUMessage(parsedHL7);
      const response = await this.notificationService.sendOruMessage(resultHL7);
      res.status(HttpStatus.OK);
    } catch (error) {
      console.error(error);
      res.status(HttpStatus.INTERNAL_SERVER_ERROR).send('An error occurred');
    }
  }
}
