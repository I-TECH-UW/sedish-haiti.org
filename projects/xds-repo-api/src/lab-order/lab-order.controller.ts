import { Controller, Post, Body } from '@nestjs/common';
import { LabOrderService } from './lab-order.service';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';


@Controller('lab-orders')
export class LabOrderController {

  constructor(private readonly labOrderService: LabOrderService) {}  

  @Post()
  async create(@Body() xmlPayload) {
    const createLabOrderDto: CreateLabOrderDto = {
      documentId: parsedData.documentId,
      labOrderId: parsedData.labOrderId,
      facilityId: parsedData.facilityId,
      documentContents: parsedData.documentContents,
    };
    return this.labOrderService.create(createLabOrderDto);
  }
}