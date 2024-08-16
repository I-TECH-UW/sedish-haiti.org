import { Controller, Post, Body } from '@nestjs/common';
import { LabResultService } from './lab-result.service';
import { CreateLabResultDto } from './dto/create-lab-result.dto';
import { LabResult } from './lab-result.schema';

@Controller('lab-results')
export class LabResultController {
  constructor(private readonly labResultService: LabResultService) {}

  @Post('create')
  async create(@Body() xmlPayload: any) {
    let labResult: LabResult = await this.labResultService.parseLabResultDocument(xmlPayload);

    return this.labResultService.create(labResult);
  }

  @Post('get-by-facility')
  async findAll(@Body() xmlPayload: any) {
    let parsedData = await this.labResultService.parseLabResultRequest(xmlPayload);

    return this.labResultService.findAllByFacilityId(parsedData.facilityId);
  }
}
