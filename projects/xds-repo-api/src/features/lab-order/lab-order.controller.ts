import { Controller, Post, Body, Get, Header } from '@nestjs/common';
import { Request } from 'express';
import { LabOrderService } from './lab-order.service';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';
import { LabOrder, LabOrderDocument } from './lab-order.schema';


@Controller('lab-orders')
export class LabOrderController {

  constructor(private readonly labOrderService: LabOrderService) {}  

  @Post('create')
  async create(@Body() body: string) {
    const labOrder: LabOrder = this.labOrderService.parseLabOrderDocument(body)

    return this.labOrderService.create(labOrder);
  }

  @Post('get-by-id')
  @Header('Content-Type', 'multipart/related;start="<rootpart*59239_818160219.1723569579332@example.jaxws.sun.com>";type="application/xop+xml";boundary="uuid:59239_818160219.1723569579332";start-info="application/soap+xml;action=\"urn:ihe:iti:2007:RetrieveDocumentSet\""')
  async getLabOrderById(@Body() xmlPayload: any) {
    const documentId = this.labOrderService.parseLabOrderRequest(xmlPayload);
    let result = await this.labOrderService.findById(documentId);

    if(result && result.length == 1) {
      return this.labOrderService.decorateLabOrderResponse(result[0]);  
    } else {
      return this.labOrderService.documentNotFoundResponse(documentId);
    }
  }

  @Get()
  async getAll() {
    return this.labOrderService.findAll();
  }
}