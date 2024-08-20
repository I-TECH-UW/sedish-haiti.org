import { Controller, Post, Body, Get, Header } from '@nestjs/common';
import { LabOrderService } from './lab-order.service';
import { LabOrder } from './lab-order.schema';
import { ApiTags } from '@nestjs/swagger';

@Controller('lab-orders')
@ApiTags('lab-orders')
export class LabOrderController {
  constructor(private readonly labOrderService: LabOrderService) {}

  @Post('create')
  async create(@Body() body: string) {
    const labOrder: LabOrder =
      await this.labOrderService.parseLabOrderDocument(body);

    return this.labOrderService.create(labOrder);
  }

  // Multipart/Related; boundary="----=_Part_2619_649687092.1716989110121"; type="application/xop+xml"; start-info="application/soap+xml";charset=UTF-8
  // Multipart/Related; boundary="----=_Part_59913_1123706865.1723834505685"; type="application/xop+xml"; start-info="application/soap+xml";charset=UTF-8
  @Post('get-by-id')
  @Header(
    'Content-Type',
    'multipart/related;start="<rootpart*59239_818160219.1723569579332@example.jaxws.sun.com>";type="application/xop+xml";boundary="uuid:59239_818160219.1723569579332";start-info="application/soap+xml;action="urn:ihe:iti:2007:RetrieveDocumentSet""',
  )
  async getLabOrderById(@Body() xmlPayload: any) {
    const documentId = this.labOrderService.parseLabOrderRequest(xmlPayload);
    const result = await this.labOrderService.findById(documentId);

    if (result && result.length == 1) {
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
