import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Notification, NotificationDocument } from './notification.schema';

@Injectable()
export class NotificationDAO {
  constructor(
    @InjectModel(Notification.name)
    private notificationModel: Model<NotificationDocument>,
  ) {}

  async find(filter: any): Promise<Notification[]> {
    return this.notificationModel.find(filter).exec();
  }

  async create(notification: Notification): Promise<Notification> {
    const createdNotification = new this.notificationModel(notification);
    return createdNotification.save();
  }

  async findById(id: string): Promise<Notification | null> {
    return this.notificationModel.findById(id).exec();
  }

  async update(
    id: Types.ObjectId,
    updateData: Partial<Notification>,
  ): Promise<Notification | null> {
    return this.notificationModel
      .findByIdAndUpdate(id, updateData, { new: true })
      .exec();
  }
}
