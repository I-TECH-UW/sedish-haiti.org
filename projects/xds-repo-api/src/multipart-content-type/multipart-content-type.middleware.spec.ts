import { MultipartContentTypeMiddleware } from './multipart-content-type.middleware';

describe('MultipartContentTypeMiddleware', () => {
  it('should be defined', () => {
    expect(new MultipartContentTypeMiddleware()).toBeDefined();
  });
});
