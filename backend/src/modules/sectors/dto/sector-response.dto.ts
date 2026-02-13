export class SectorResponseDto {
  private readonly id: string;
  private readonly name: string;
  private readonly createdAt: Date;

  constructor(id: string, name: string, createdAt: Date) {
    this.id = id;
    this.name = name;
    this.createdAt = createdAt;
  }
}
