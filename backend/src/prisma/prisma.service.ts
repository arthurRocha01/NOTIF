import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  constructor() {
    const url = process.env.DATABASE_URL ?? '';
    const serverlessUrl =
      process.env.VERCEL && !url.includes('pgbouncer=true')
        ? `${url}${url.includes('?') ? '&' : '?'}pgbouncer=true&connection_limit=1`
        : url;

    super({
      log: ['warn', 'error'],
      datasources: { db: { url: serverlessUrl } },
    });
  }

  async onModuleInit() {
    await this.$connect();
  }
}
