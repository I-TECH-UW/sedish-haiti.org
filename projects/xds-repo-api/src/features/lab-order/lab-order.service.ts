import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { LabOrder } from './lab-order.schema';
import { LabOrderDAO } from './lab-order.dao';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';

@Injectable()
export class LabOrderService {
  constructor(private readonly labOrderDAO: LabOrderDAO) {}

  async create(labOrder: LabOrder) {
    return  this.labOrderDAO.create(labOrder);
  }

  async findById(documentId: string) {
    return this.labOrderDAO.findByDocumentId(documentId);
  }

  parseLabOrderDocument(xmlPayload: any): LabOrder {
    const newLabOrder = new LabOrder();
    
    newLabOrder.documentId = xmlPayload.documentId;
    newLabOrder.labOrderId = xmlPayload.labOrderId;
    newLabOrder.facilityId = xmlPayload.facilityId;
    newLabOrder.documentContents = xmlPayload.documentContents;

    
    return newLabOrder
  }

  async parseLabOrderRequest(xmlPayload: any): Promise<any> {
  
    
  }
}
