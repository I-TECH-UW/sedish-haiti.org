import { Controller, Post, Body } from '@nestjs/common';
import { SubscriptionService } from './subscription.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';

@Controller('subscription')
export class SubscriptionController {
    constructor(private readonly subscriptionService: SubscriptionService) {}

    @Post()
    async create(@Body() xmlPayload) {
      const parsedData = xmlPayload;
      const createSubscriptionDto: CreateSubscriptionDto = {
        targetAddress: parsedData.targetAddress,
      };
      return this.subscriptionService.create(createSubscriptionDto);
    }
}
