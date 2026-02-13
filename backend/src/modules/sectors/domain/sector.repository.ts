import { Sector } from './sector.entity';

export interface ISectorRepository {
  findAll(): Promise<Sector[]>;
  findById(id: string): Promise<Sector>;
  create(sector: Sector): Promise<void>;
  update(string, sector: Sector): Promise<void>;
  delete(id: string): Promise<void>;
}
