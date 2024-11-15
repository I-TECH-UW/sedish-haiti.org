import { Controller, Post, Req, Res, HttpStatus } from '@nestjs/common';
import { Request, Response } from 'express';
import { NotificationService } from './notification.service';

@Controller('notify')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Post()
  async handleNotification(@Req() req: Request, @Res() res: Response) {
    const soapMessage = req.body;

    try {
      // Parse the SOAP message and extract the document ID
      const documentId = await this.notificationService.extractDocumentId(soapMessage);

      // Retrieve the HL7 message using the document ID
      const hl7Message = await this.notificationService.retrieveHL7Message(documentId);

      // Parse the HL7 message
      const parsedHL7 = this.notificationService.parseHL7Message(hl7Message);

      // Generate a random HL7 result message
      const resultHL7 = this.notificationService.generateRandomHL7Result(parsedHL7);

      // Send back the result
      const response = this.notificationService.sendHL7Result(resultHL7);
      
      res.status(HttpStatus.OK).send(response);
    } catch (error) {
      console.error(error);
      res.status(HttpStatus.INTERNAL_SERVER_ERROR).send('An error occurred');
    }
  }
}
