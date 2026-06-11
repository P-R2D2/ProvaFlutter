import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: any, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'An unexpected error occurred';
    let error = 'Internal Server Error';
    let retryable = false;

    if (exception instanceof HttpException) {
      statusCode = exception.getStatus();
      const resContent: any = exception.getResponse();
      message = typeof resContent === 'object' && resContent['message']
        ? (Array.isArray(resContent['message']) ? resContent['message'][0] : resContent['message'])
        : exception.message;
      error = exception.name;

      if ([429, 502, 503, 504].includes(statusCode)) {
        retryable = true;
      }
    } else if (exception.isAxiosError || (exception.response && exception.config)) {
      statusCode = exception.response?.status || HttpStatus.BAD_GATEWAY;

      if (statusCode === 404) {
        message = 'The requested market asset could not be found';
        error = 'Not Found';
      } else if (statusCode === 429) {
        message = 'External market service rate-limit reached. Please try again later.';
        error = 'Too Many Requests';
        retryable = true;
      } else if ([500, 502, 503, 504].includes(statusCode)) {
        message = 'Market pricing service is currently offline or unreachable. Please try again later.';
        error = 'Service Unavailable';
        retryable = true;
      } else {
        message = exception.response?.data?.message || 'External market integration failure';
        error = 'Bad Gateway';
      }
    } else {
      message = exception.message || message;
    }

    response.status(statusCode).json({
      statusCode,
      message,
      error,
      retryable,
    });
  }
}
