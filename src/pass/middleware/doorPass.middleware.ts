import {
  Injectable,
  NestMiddleware,
  UnauthorizedException,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { PassService } from '../service/pass.service';

@Injectable()
export class DoorPassMiddleware implements NestMiddleware {
  constructor(private readonly passService: PassService) {}
  async use(req: Request, res: Response, next: () => void) {
    try {
      const accessSecret: string = req.headers['access_secret'] as string;
      const code: string = req.headers['door_code'] as string;
      if (!accessSecret || accessSecret === '' || !code || code === '') {
        throw new UnauthorizedException();
      }
      const door = await this.passService.getDoorWithCode(code);
      if (!door) {
        throw new UnauthorizedException();
      }
      const isMatch = await this.passService.compareHash(
        door.access_secret,
        accessSecret,
      );
      if (!isMatch) {
        throw new UnauthorizedException();
      }
      if (door.code === code) {
        req.body.door = door;
        next();
      }
    } catch (e) {
      throw new UnauthorizedException();
    }
  }
}