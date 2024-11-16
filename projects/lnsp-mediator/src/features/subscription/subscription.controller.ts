import { Controller, Post, Body, Get } from '@nestjs/common';
import { SubscriptionService } from './subscription.service';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

@Controller('subscription')
@ApiTags('subscription')
export class SubscriptionController {
  constructor(private readonly subscriptionService: SubscriptionService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new subscription' })
  async create(@Body() xmlPayload: any) {
    const r = this.subscriptionService.handleSubscription(xmlPayload);

    // TODO: Return valid subscription response
    return r;
  }

  @Get()
  @ApiOperation({ summary: 'Get all subscriptions' })
  async getAll() {
    return this.subscriptionService.getAll();
  }
}
