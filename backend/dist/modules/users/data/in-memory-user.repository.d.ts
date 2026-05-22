import { User } from '../domain/user.entity';
export declare const USER_REPOSITORY = "USER_REPOSITORY";
export interface UserRepository {
    save(user: User): Promise<User>;
    findByEmail(email: string): Promise<User | null>;
    findById(id: string): Promise<User | null>;
    update(user: User): Promise<User>;
}
export declare class InMemoryUserRepository implements UserRepository {
    private users;
    save(user: User): Promise<User>;
    findByEmail(email: string): Promise<User | null>;
    findById(id: string): Promise<User | null>;
    update(user: User): Promise<User>;
}
