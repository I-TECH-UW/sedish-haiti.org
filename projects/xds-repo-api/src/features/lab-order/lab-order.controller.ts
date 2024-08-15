import { Controller, Post, Body } from '@nestjs/common';
import { LabOrderService } from './lab-order.service';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';
import { LabOrder } from './lab-order.schema';


@Controller('lab-orders')
export class LabOrderController {

  constructor(private readonly labOrderService: LabOrderService) {}  

  @Post('create')
  async create(@Body() xmlPayload: any) {
    const labOrder: LabOrder = this.labOrderService.parseLabOrderDocument(xmlPayload)

    return this.labOrderService.create(labOrder);
  }

  @Post('getByID')
  getLabOrderById(@Body() xmlPayload: any) {
    

    return this.labOrderService.findById(xmlPayload.labOrderId);
  }
}