import { Model } from 'mongoose';
import { DAO } from '../../core/database/database.dao';
import { LabOrder, LabOrderDocument } from './lab-order.schema';
export declare class LabOrderDAO extends DAO<LabOrderDocument> {
    constructor(model: Model<LabOrderDocument>);
    findByDocumentId(documentId: string): Promise<(import("mongoose").Document<unknown, {}, import("mongoose").Document<unknown, {}, LabOrder> & LabOrder & {
        _id: import("mongoose").Types.ObjectId;
    }> & import("mongoose").Document<unknown, {}, LabOrder> & LabOrder & {
        _id: import("mongoose").Types.ObjectId;
    } & Required<{
        _id: import("mongoose").Types.ObjectId;
    }>)[]>;
}
