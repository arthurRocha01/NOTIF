import { v4 as uuidv4 } from 'uuid';

export class Sector {
  private readonly id: string;
  private name: string;
  private createdAt: Date;

  constructor(id: string, name: string, createdAt: Date) {
    this.id = id;
    this.name = name;
    this.createdAt = createdAt;
  }

  static create(name: string) {
    const id = uuidv4();
    const createdAt = new Date();

    return new Sector(id, name, createdAt);
  }

  public getId(): string {
    return this.id;
  }
  public getName(): string {
    return this.name;
  }

  public getCreatedAt(): Date {
    return this.createdAt;
  }

  public changeName(name: string) {
    if (name === this.name) {
      return;
    }

    this.name = name;
  }
}
