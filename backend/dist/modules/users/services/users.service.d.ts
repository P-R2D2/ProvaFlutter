import { User } from '../domain/user.entity';
import { type UserRepository } from '../data/in-memory-user.repository';
export declare class UsersService {
    private readonly userRepository;
    constructor(userRepository: UserRepository);
    create(email: string, passwordPlain: string): Promise<User>;
    findByEmail(email: string): Promise<User | null>;
    findById(id: string): Promise<User | null>;
    update(user: User): Promise<User>;
}
