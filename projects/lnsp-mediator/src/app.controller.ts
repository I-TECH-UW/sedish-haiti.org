import { Controller, Post, Body, Res, HttpStatus } from '@nestjs/common';
import { LabOrderService } from './features/lab-order/lab-order.service';
import { LabResultService } from './features/lab-result/lab-result.service';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';

@Controller()
@ApiTags('api')
export class AppController {
  constructor(
    private readonly labOrderService: LabOrderService,
    private readonly labResultService: LabResultService,
  ) {}

  @Post()
  async handleRequest(@Body() body: any, @Res() res: Response) {
    try {
      let serviceResponse;
      if(!body || typeof body !== 'string') {
        res.status(HttpStatus.BAD_REQUEST).send('Invalid request body');
        return;
      }

      if (body.split('\n').some(line => line.startsWith('Content-Type:') && line.includes('urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b'))) {
          serviceResponse = await this.labOrderService.handleCreateLabOrder(body);
      } else {
        serviceResponse = await this.labResultService.handleCreateLabResult(body);
      }

    if (!serviceResponse) {
      res.status(HttpStatus.BAD_REQUEST).send('Invalid service response');
      return;
    }

    const { contentType, responseBody, status } = serviceResponse;
      res.setHeader('Content-Type', contentType);
      res.status(status).write(responseBody);
    } catch (error) {
      res.status(HttpStatus.INTERNAL_SERVER_ERROR).write('Internal Server Error');
    } finally {
      res.end();
    }
  }
}