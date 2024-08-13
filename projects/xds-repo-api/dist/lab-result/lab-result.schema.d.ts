import { Document } from 'mongoose';
export declare class LabResult extends Document {
    facilityId: string;
    labOrderId: string;
    documentId: string;
    documentContents: string;
}
export declare const LabResultSchema: import("mongoose").Schema<LabResult, import("mongoose").Model<LabResult, any, any, any, Document<unknown, any, LabResult> & LabResult & Required<{
    _id: unknown;
}>, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, LabResult, Document<unknown, {}, import("mongoose").FlatRecord<LabResult>> & import("mongoose").FlatRecord<LabResult> & Required<{
    _id: unknown;
}>>;
