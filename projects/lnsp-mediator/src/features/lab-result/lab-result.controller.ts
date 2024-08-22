import { Controller, Post, Body, Res } from '@nestjs/common';
import { LabResultService } from './lab-result.service';
import { LabResult } from './lab-result.schema';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';
import { HttpStatusCode } from 'axios';

@Controller('lab-results')
@ApiTags('lab-results')
export class LabResultController {
  constructor(private readonly labResultService: LabResultService) {}

  @Post('create')
  async create(@Body() xmlPayload: any, @Res() res: Response) {
    const contentType =
      'Multipart/Related; boundary="----=_Part_59931_102464640.1723834961072"; type="application/xop+xml"; start-info="application/soap+xml";charset=UTF-8';
    res.setHeader('Content-Type', contentType);

    try {
      const labResult: LabResult =
        await this.labResultService.parseLabResultDocument(xmlPayload);

      const createdLabResult = await this.labResultService.create(labResult);

      if (createdLabResult) {
        res.status(HttpStatusCode.Ok);
        res.write(this.labResultService.labResultSubmissionSuccess());
      } else {
        res.status(HttpStatusCode.UnprocessableEntity);
        res.write(this.labResultService.labResultSubmissionGeneralFailure());
      }
    } catch (error) {
      console.log(error);
      res.status(HttpStatusCode.InternalServerError);
      res.write(this.labResultService.labResultSubmissionGeneralFailure());
    }

    res.end();
  }

  @Post('get-by-facility')
  async findAll(@Body() xmlPayload: any, @Res() res: Response) {
    const contentType = 'application/xml; charset=UTF-8';
    res.setHeader('Content-Type', contentType);
    try {
      const parsedData =
        await this.labResultService.parseLabResultRequest(xmlPayload);

      const resultList = await this.labResultService.findAllByFacilityId(
        parsedData.facilityId,
        parsedData.maxNumber,
      );

      if (resultList.length === 0) {
        res.status(HttpStatusCode.NotFound);
      } else {
        const responseBody =
          this.labResultService.decorateResultList(resultList);

        res.status(HttpStatusCode.Accepted);
        res.write(responseBody);
      }
    } catch (error) {
      res.status(HttpStatusCode.InternalServerError);
    }
    res.end();
  }
}
