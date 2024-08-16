import { Controller, Post, Body, Get, Headers } from '@nestjs/common';
import { Request } from 'express';
import { LabOrderService } from './lab-order.service';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';
import { LabOrder } from './lab-order.schema';


@Controller('lab-orders')
export class LabOrderController {

  constructor(private readonly labOrderService: LabOrderService) {}  

  @Post('create')
  async create(@Body() body: string) {
    const labOrder: LabOrder = this.labOrderService.parseLabOrderDocument(body)

    return this.labOrderService.create(labOrder);
  }

  @Post('get-by-id')
  getLabOrderById(@Body() xmlPayload: any) {
    const documentId = this.labOrderService.parseLabOrderRequest(xmlPayload);
    let result = this.labOrderService.findById(documentId);

    if(result) {
      return result;  
    } else {
      return this.labOrderService.documentNotFoundResponse(documentId);
    }
  }

  @Get()
  async getAll() {
    return this.labOrderService.findAll();
  }
}