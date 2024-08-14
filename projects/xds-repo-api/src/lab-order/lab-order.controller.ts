import { Controller, Post, Body } from '@nestjs/common';
import { LabOrderService } from './lab-order.service';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';


@Controller('lab-orders')
export class LabOrderController {

  constructor(private readonly labOrderService: LabOrderService) {}  

  @Post('create')
  async create(@Body() xmlPayload: any) {
    let parsedData = this.labOrderService.parseLabOrderDocument(xmlPayload)
    const createLabOrderDto: CreateLabOrderDto = {
      documentId: parsedData.documentId,
      labOrderId: parsedData.labOrderId,
      facilityId: parsedData.facilityId,
      documentContents: parsedData.documentContents,
    };
    return this.labOrderService.create(createLabOrderDto);
  }

  @Post('getByID')
  getLabOrderById(@Body() xmlPayload: any) {
    

    return this.labOrderService.findById(xmlPayload.labOrderId);
  }
}