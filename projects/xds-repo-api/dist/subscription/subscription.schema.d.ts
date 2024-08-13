import { Document } from 'mongoose';
export declare class Subscription extends Document {
    targetAddress: string;
}
export declare const SubscriptionSchema: import("mongoose").Schema<Subscription, import("mongoose").Model<Subscription, any, any, any, Document<unknown, any, Subscription> & Subscription & Required<{
    _id: unknown;
}>, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, Subscription, Document<unknown, {}, import("mongoose").FlatRecord<Subscription>> & import("mongoose").FlatRecord<Subscription> & Required<{
    _id: unknown;
}>>;
