import { Controller, Post, Body } from '@nestjs/common';
import { LabResultService } from './lab-result.service';
import { LabResult } from './lab-result.schema';
import { ApiTags } from '@nestjs/swagger';

@Controller('lab-results')
@ApiTags('lab-results')
export class LabResultController {
  constructor(private readonly labResultService: LabResultService) {}

  @Post('create')
  async create(@Body() xmlPayload: any) {
    const labResult: LabResult =
      await this.labResultService.parseLabResultDocument(xmlPayload);

    return this.labResultService.create(labResult);
  }

  @Post('get-by-facility')
  async findAll(@Body() xmlPayload: any) {
    const parsedData =
      await this.labResultService.parseLabResultRequest(xmlPayload);

    return this.labResultService.findAllByFacilityId(parsedData.facilityId);
  }
}
