import { Controller, Post, Body } from '@nestjs/common';
import { SubscriptionService } from './subscription.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';

@Controller('subscription')
export class SubscriptionController {
    constructor(private readonly subscriptionService: SubscriptionService) {}

    @Post()
    async create(@Body() xmlPayload: any) {
      let targetAddress = xmlPayload["soap:envelope"]["soap:body"][0]["wsnt:subscribe"][0]["wsnt:consumerreference"][0]["wsa:address"][0]

      const createSubscriptionDto: CreateSubscriptionDto = {
        targetAddress: targetAddress,
      };
      
      let r = this.subscriptionService.create(createSubscriptionDto);

      return r
    }

    @Get()
    async getAll() {
      return this.subscriptionService.getAll();
    }
}
