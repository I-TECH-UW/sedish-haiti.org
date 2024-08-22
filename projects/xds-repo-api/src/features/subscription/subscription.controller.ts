import { Controller, Post, Body, Get } from '@nestjs/common';
import { SubscriptionService } from './subscription.service';
import { Subscription } from './subscription.schema';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

@Controller('subscription')
@ApiTags('subscription')
export class SubscriptionController {
  constructor(private readonly subscriptionService: SubscriptionService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new subscription' })
  async create(@Body() xmlPayload: any) {
    const targetAddress =
      xmlPayload['soap:envelope']['soap:body'][0]['wsnt:subscribe'][0][
        'wsnt:consumerreference'
      ][0]['wsa:address'][0];

    const subscriptionData: Subscription = {
      targetAddress: targetAddress,
    };

    const r = this.subscriptionService.create(subscriptionData);

    return r;
  }

  @Get()
  @ApiOperation({ summary: 'Get all subscriptions' })
  async getAll() {
    return this.subscriptionService.getAll();
  }
}
