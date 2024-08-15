import { Controller, Post, Body, Get, Headers } from '@nestjs/common';
import { Request } from 'express';
import { LabOrderService } from './lab-order.service';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';
import { LabOrder } from './lab-order.schema';


@Controller('lab-orders')
export class LabOrderController {

  constructor(private readonly labOrderService: LabOrderService) {}  

  @Post('create')
  async create(@Body() body: string, @Headers('content-type') contentType: string) {
    const labOrder: LabOrder = new LabOrder();// this.labOrderService.parseLabOrderDocument(xmlPayload)

    return this.labOrderService.create(labOrder);
  }

  // @Post('create')
  // create(@Req() req: RawBodyRequest<Request>) {
  //   // const labOrder: LabOrder = this.labOrderService.parseLabOrderDocument(xmlPayload)
  //   const raw = req.rawBody;

  //   const labOrder = new LabOrder();
  //   return this.labOrderService.create(labOrder);
  // }


  @Post('getByDocumentID')
  getLabOrderById(@Body() xmlPayload: any) {
    return this.labOrderService.findById(xmlPayload.documentId);
  }

  @Get()
  async getAll() {
    return this.labOrderService.findAll();
  }
}