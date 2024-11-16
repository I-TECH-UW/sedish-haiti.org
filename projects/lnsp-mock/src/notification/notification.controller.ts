// src/notification/notification.controller.ts
import { Controller, Post, Res, HttpStatus, Body } from '@nestjs/common';
import { Response } from 'express';
import { NotificationService } from './notification.service';

@Controller('notify')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post()
  async handleNotification(@Body() body: string, @Res() res: Response) {
    const soapMessage = body;

    try {
      const documentId =
        await this.notificationService.extractDocumentId(soapMessage);
      const hl7Message =
        await this.notificationService.retrieveORMMessage(documentId);
      const parsedHL7 = this.notificationService.parseORMMessage(hl7Message);
      const resultHL7 = this.notificationService.generateORUMessage(parsedHL7);
      const response = await this.notificationService.sendOruMessage(resultHL7);
      res.status(HttpStatus.OK);
      console.log(response);
    } catch (error) {
      console.error(error);
      res.status(HttpStatus.INTERNAL_SERVER_ERROR).send('An error occurred');
    }
  }
}
