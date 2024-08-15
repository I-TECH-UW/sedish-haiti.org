import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import * as rawBodyParser from 'body-parser';

@Injectable()
export class MultipartContentTypeMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const multipartContentTypePrefix = 'multipart/related';

    if (req.headers['content-type']?.startsWith(multipartContentTypePrefix)) {
      // Apply the text parser only for this specific Content-Type
      rawBodyParser.text({ type: () => true })(req, res, next);
    } else {
      // Continue to the next middleware if Content-Type doesn't match
      next();
    }
  }
}