import { Model } from 'mongoose';
import { LabOrder } from './lab-order.schema';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';
export declare class LabOrderService {
    private labOrderModel;
    constructor(labOrderModel: Model<LabOrder>);
    create(createLabOrderDto: CreateLabOrderDto): Promise<LabOrder>;
    findById(id: string): Promise<LabOrder | null>;
    parseLabOrderDocument(xmlPayload: any): Promise<any>;
    parseLabOrderRequest(xmlPayload: any): Promise<any>;
}
