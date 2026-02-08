export class User {
  private readonly id: string;
  private name: string;
  private email: string;
  
  constructor(id: string, name: string, email: string) {
    this.id = id;
    this.name = name;
    this.email = email;
  }

  changeName(name: string): void {
    if (name === this.name) {
      return;
    }
    this.name = name;
  }

  getId(): string {
    return this.id;
  }
  
  getName(): string {
    return this.name
  }

  getEmail(): string {
    return this.email;
  }
}