import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { JwtPayload } from '../../domain/jwt-payload.interface';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'secretKeyTemporaria', // Use variáveis de ambiente!
    });
  }

  validate(payload: JwtPayload) {
    // O que você retornar aqui será injetado em `request.user` nas rotas protegidas
    return { userId: payload.sub, email: payload.email };
  }
}
