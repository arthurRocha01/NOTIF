export interface AuthenticatedRequest {
  user: {
    userId: string;
    role: string;
    sectorId: string;
  };
}
