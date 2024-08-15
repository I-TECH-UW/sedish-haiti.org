import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';


export type SubscriptionDocument = HydratedDocument<Subscription>;

@Schema()
export class Subscription {
  @Prop({ required: true })
  targetAddress: string;
}

export const SubscriptionSchema = SchemaFactory.createForClass(Subscription);