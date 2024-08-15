import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema()
export class Subscription extends Document {
  @Prop({ required: true })
  targetAddress: string;
}

export const SubscriptionSchema = SchemaFactory.createForClass(Subscription);