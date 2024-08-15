import { LabOrderService } from './lab-order.service';
import { LabOrder } from './lab-order.schema';
export declare class LabOrderController {
    private readonly labOrderService;
    constructor(labOrderService: LabOrderService);
    create(xmlPayload: any): Promise<(import("mongoose").Document<unknown, {}, import("mongoose").Document<unknown, {}, LabOrder> & LabOrder & {
        _id: import("mongoose").Types.ObjectId;
    }> & {
        _id: import("mongoose").Types.ObjectId;
    }) | (import("mongoose").Document<unknown, {}, import("mongoose").Document<unknown, {}, LabOrder> & LabOrder & {
        _id: import("mongoose").Types.ObjectId;
    }> & {
        _id?: unknown;
    } & Required<{
        _id: unknown;
    }>)>;
    getLabOrderById(xmlPayload: any): Promise<(import("mongoose").Document<unknown, {}, import("mongoose").Document<unknown, {}, LabOrder> & LabOrder & {
        _id: import("mongoose").Types.ObjectId;
    }> & import("mongoose").Document<unknown, {}, LabOrder> & LabOrder & {
        _id: import("mongoose").Types.ObjectId;
    } & Required<{
        _id: import("mongoose").Types.ObjectId;
    }>)[]>;
}
