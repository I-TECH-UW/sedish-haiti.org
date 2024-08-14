import { Controller, Post, Body } from '@nestjs/common';
import { LabResultService } from './lab-result.service';
import { CreateLabResultDto } from './dto/create-lab-result.dto';

const parser = new XMLParser();

@Controller('lab-results')
export class LabResultController {
  constructor(private readonly labResultService: LabResultService) {}

  @Post()
  async create(@Body() xmlPayload: any) {
    let parsed_data = this.labResultService.parseLabResultDocument(xmlPayload);

    const createLabResultDto: CreateLabResultDto = {
      facilityId: parsedData.facilityId,
      labOrderId: parsedData.labOrderId,
      documentId: parsedData.documentId,
      documentContents: parsedData.documentContents,
    };
    return this.labResultService.create(createLabResultDto);
  }

  @Post('dsub')
  findAll(@Body() xmlPayload: any) {
    let parsedData = this.labResultService.parseLabResultRequest(xmlPayload);

    return this.labResultService.findAllByFacilityId(parsedData.facilityId);
  }
}
