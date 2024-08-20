import { Controller, Post, Body, Get, Header, Res, HttpStatus } from '@nestjs/common';
import { LabOrderService } from './lab-order.service';
import { LabOrder } from './lab-order.schema';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';

@Controller('lab-orders')
@ApiTags('lab-orders')
export class LabOrderController {
  constructor(private readonly labOrderService: LabOrderService) {}

  @Post('create')
  async create(@Body() body: string, @Res() res: Response) {
    const contentType = 'Multipart/Related; boundary="----=_Part_60435_1628391534.1724167510003"; type="application/xop+xml"; start-info="application/soap+xml";charset=UTF-8';
    res.setHeader('Content-Type', contentType);

    let responseBody;
    try {
      const labOrder: LabOrder =
      await this.labOrderService.parseLabOrderDocument(body);

      const result = await this.labOrderService.create(labOrder);

      // check if the lab order was created successfully
      if (result) {
        responseBody = this.labOrderService.labOrderSubmissionSuccess();
        res.status(HttpStatus.OK);
      } else {
        responseBody = this.labOrderService.labOrderSubmissionGeneralFailure();
        res.status(HttpStatus.UNPROCESSABLE_ENTITY);
      }
    } catch (error) {
      res.status(HttpStatus.INTERNAL_SERVER_ERROR);
      responseBody = this.labOrderService.labOrderSubmissionGeneralFailure();
    }

    res.write(responseBody);
    res.end();
  }

  // Multipart/Related; boundary="----=_Part_2619_649687092.1716989110121"; type="application/xop+xml"; start-info="application/soap+xml";charset=UTF-8
  // Multipart/Related; boundary="----=_Part_59913_1123706865.1723834505685"; type="application/xop+xml"; start-info="application/soap+xml";charset=UTF-8
  @Post('get-by-id')
  async getLabOrderById(@Body() xmlPayload: any, @Res() res: Response) {
    const documentId = this.labOrderService.parseLabOrderRequest(xmlPayload);
    const result = await this.labOrderService.findById(documentId);

    const contentType =
      'multipart/related;start="<rootpart*59239_818160219.1723569579332@example.jaxws.sun.com>";type="application/xop+xml";boundary="uuid:59239_818160219.1723569579332";start-info="application/soap+xml;action="urn:ihe:iti:2007:RetrieveDocumentSet""';

    res.setHeader('Content-Type', contentType);

    if (result && result.length === 1) {
      const responseBody = this.labOrderService.decorateLabOrderResponse(result[0]);
      res.status(HttpStatus.OK);
      res.write(responseBody);
    } else {
      const notFoundResponse = this.labOrderService.documentNotFoundResponse(documentId);
      res.status(HttpStatus.NOT_FOUND);
      res.write(notFoundResponse);
    }

    // End the response
    res.end();
  }

  @Get()
  async getAll() {
    return this.labOrderService.findAll();
  }
}
