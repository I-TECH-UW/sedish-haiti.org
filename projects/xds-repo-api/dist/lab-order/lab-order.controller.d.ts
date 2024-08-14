import { LabOrderService } from './lab-order.service';
export declare class LabOrderController {
    private readonly labOrderService;
    constructor(labOrderService: LabOrderService);
    create(xmlPayload: any): Promise<import("./lab-order.schema").LabOrder>;
    getLabOrderById(xmlPayload: any): Promise<import("./lab-order.schema").LabOrder | null>;
}
