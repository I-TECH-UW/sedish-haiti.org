import * as mongoose from 'mongoose';
import { HydratedDocument } from 'mongoose';
import { LabResult } from '../lab-result/lab-result.schema';
export type LabOrderDocument = HydratedDocument<LabOrder>;
export declare class LabOrder {
    documentId: string;
    labOrderId: string;
    facilityId: string;
    documentContents: string;
    submittedAt: Date;
    retrievedAt: Date;
    resultedAt: Date;
    result: LabResult;
}
export declare const LabOrderSchema: mongoose.Schema<LabOrder, mongoose.Model<LabOrder, any, any, any, mongoose.Document<unknown, any, LabOrder> & LabOrder & {
    _id: mongoose.Types.ObjectId;
}, any>, {}, {}, {}, {}, mongoose.DefaultSchemaOptions, LabOrder, mongoose.Document<unknown, {}, mongoose.FlatRecord<LabOrder>> & mongoose.FlatRecord<LabOrder> & {
    _id: mongoose.Types.ObjectId;
}>;
