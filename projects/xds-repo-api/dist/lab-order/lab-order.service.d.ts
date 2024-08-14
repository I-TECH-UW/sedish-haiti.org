import { Model } from 'mongoose';
import { LabOrder } from './schemas/lab-order.schema';
import { CreateLabOrderDto } from './dto/create-lab-order.dto';
export declare class LabOrderService {
    private labOrderModel;
    constructor(labOrderModel: Model<LabOrder>);
    create(createLabOrderDto: CreateLabOrderDto): Promise<LabOrder>;
    findById(id: string): Promise<LabOrder>;
    parseLabOrderDocument(xmlPayload: any): any;
    parseLabOrderRequest(xmlPayload: any): any;
}
