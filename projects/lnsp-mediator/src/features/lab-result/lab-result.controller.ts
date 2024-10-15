import { Controller, Post, Body, Res, HttpStatus } from '@nestjs/common';
import { LabResultService } from './lab-result.service';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';

@Controller('lab-results')
@ApiTags('lab-results')
export class LabResultController {
  constructor(private readonly labResultService: LabResultService) {}

  @Post('create')
  async create(@Body() xmlPayload: any, @Res() res: Response) {
    try {
      const { contentType, responseBody, status } = await this.labResultService.handleCreateLabResult(xmlPayload);
      res.setHeader('Content-Type', contentType);
      res.status(status);
      res.write(responseBody);
    } catch (error) {
      res.status(HttpStatus.INTERNAL_SERVER_ERROR).write('Internal Server Error');
    } finally {
      res.end();
    }
  }

  @Post('get-by-facility')
  async findAll(@Body() xmlPayload: any, @Res() res: Response) {
    try {
      const { contentType, responseBody, status } = await this.labResultService.handleGetLabResultsByFacility(xmlPayload);
      res.setHeader('Content-Type', contentType);
      res.status(status);
      res.write(responseBody);
    } catch (error) {
      res.status(HttpStatus.INTERNAL_SERVER_ERROR).write('Internal Server Error');
    } finally {
      res.end();
    }
  }
}