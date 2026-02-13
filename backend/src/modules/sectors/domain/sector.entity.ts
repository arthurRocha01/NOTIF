import { v4 as uuidv4 } from 'uuid';

export class Sector {
  private constructor(
    private readonly id: string,
    private name: string,
    private createdAt: Date,
    private updatedAt: Date,
  ) {
    this.id = id;
    this.name = name;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  public static create(name: string) {
    const id = uuidv4();
    const createdAt = new Date();
    const updatedAt = new Date();

    return new Sector(id, name, createdAt, updatedAt);
  }

  public static reconstitute(
    id: string,
    name: string,
    createdAt: Date,
    updatedAt: Date,
  ): Sector {
    return new Sector(id, name, createdAt, updatedAt);
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

  public getUpdatedAt(): Date {
    return this.updatedAt;
  }

  public changeName(name: string) {
    if (name === this.name) {
      return;
    }

    this.name = name;
  }
}
