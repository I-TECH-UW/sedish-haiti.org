import { Controller, Post, Body, Res, HttpStatus } from '@nestjs/common';
import { LabOrderService } from './features/lab-order/lab-order.service';
import { LabResultService } from './features/lab-result/lab-result.service';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';

@Controller('api')
@ApiTags('api')
export class AppController {
  constructor(
    private readonly labOrderService: LabOrderService,
    private readonly labResultService: LabResultService,
  ) {}

  @Post('entrypoint')
  async handleRequest(@Body() body: any, @Res() res: Response) {
    try {
      let serviceResponse;
      if (body.type === 'labOrder') {
        if (body.action === 'create') {
          serviceResponse = await this.labOrderService.handleCreateLabOrder(body.payload);
        } else if (body.action === 'getById') {
          serviceResponse = await this.labOrderService.handleGetLabOrderById(body.payload);
        }
      } else if (body.type === 'labResult') {
        if (body.action === 'create') {
          serviceResponse = await this.labResultService.handleCreateLabResult(body.payload);
        } else if (body.action === 'getByFacility') {
          serviceResponse = await this.labResultService.handleGetLabResultsByFacility(body.payload);
        }
      } else {
        res.status(HttpStatus.BAD_REQUEST).send('Unsupported type or action');
        return;
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