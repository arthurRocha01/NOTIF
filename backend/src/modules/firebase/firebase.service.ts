import { Injectable, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService {
  private readonly logger = new Logger(FirebaseService.name);

  onModuleInit() {
    if (!admin.app.length) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        }),
      });
      this.logger.log('Firebase Admin inicializado');
    }
  }

  async sendToDevice(token: string, title: string, body: string, data?: any) {
    try {
      await admin.messaging().send({
        token: token,
        notification: {
          title: title,
          body: body,
        },
        data: {
          ...data,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: { priority: 'high' },
        apns: { payload: { aps: { contentAvailable: true } } },
      });

      this.logger.log(`Push enviado para token ${token.substring(0, 10)}...`);
    } catch (error) {
      this.logger.error(`Falha ao enviar push: ${error}`);
    }
  }
}
