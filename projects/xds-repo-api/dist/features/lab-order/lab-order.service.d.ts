import { LabOrder } from './lab-order.schema';
import { LabOrderDAO } from './lab-order.dao';
export declare class LabOrderService {
    private readonly labOrderDAO;
    constructor(labOrderDAO: LabOrderDAO);
    create(labOrder: LabOrder): Promise<(import("mongoose").Document<unknown, {}, import("mongoose").Document<unknown, {}, LabOrder> & LabOrder & {
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
    findById(documentId: string): Promise<(import("mongoose").Document<unknown, {}, import("mongoose").Document<unknown, {}, LabOrder> & LabOrder & {
        _id: import("mongoose").Types.ObjectId;
    }> & import("mongoose").Document<unknown, {}, LabOrder> & LabOrder & {
        _id: import("mongoose").Types.ObjectId;
    } & Required<{
        _id: import("mongoose").Types.ObjectId;
    }>)[]>;
    parseLabOrderDocument(xmlPayload: any): LabOrder;
    parseLabOrderRequest(xmlPayload: any): Promise<any>;
}
