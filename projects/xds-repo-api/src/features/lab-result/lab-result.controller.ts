import { Controller, Post, Body } from '@nestjs/common';
import { LabResultService } from './lab-result.service';
import { CreateLabResultDto } from './dto/create-lab-result.dto';

@Controller('lab-results')
export class LabResultController {
  constructor(private readonly labResultService: LabResultService) {}

  @Post()
  async create(@Body() xmlPayload: any) {
    let parsedData = await this.labResultService.parseLabResultDocument(xmlPayload);

    const createLabResultDto: CreateLabResultDto = {
      facilityId: parsedData.facilityId,
      labOrderId: parsedData.labOrderId,
      documentId: parsedData.documentId,
      documentContents: parsedData.documentContents,
    };
    return this.labResultService.create(createLabResultDto);
  }

  @Post('dsub')
  async findAll(@Body() xmlPayload: any) {
    let parsedData = await this.labResultService.parseLabResultRequest(xmlPayload);

    return this.labResultService.findAllByFacilityId(parsedData.facilityId);
  }
}
