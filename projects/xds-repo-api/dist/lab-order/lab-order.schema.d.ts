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
