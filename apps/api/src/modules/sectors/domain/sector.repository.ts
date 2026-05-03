import { Sector } from './sector.entity';

export interface ISectorRepository {
  findAll(): Promise<Sector[]>;
  findById(id: string): Promise<Sector>;
  findByName(name: string): Promise<Sector | null>;
  save(sector: Sector): Promise<void>;
  update(idsector: Sector): Promise<void>;
  delete(id: string): Promise<void>;
}
