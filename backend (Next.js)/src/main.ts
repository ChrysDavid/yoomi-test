import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.enableCors({
    origin: [/^http:\/\/localhost:\d+$/],
    credentials: true,
  });
  
  app.useGlobalPipes(new ValidationPipe({ 
    whitelist: true,
    transform: true
  }));
  
  await app.listen(3000);
  console.log('Server running on http://10.0.2.2:3000');
}
bootstrap();