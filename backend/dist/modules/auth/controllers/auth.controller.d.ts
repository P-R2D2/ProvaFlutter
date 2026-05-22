import { RegisterDto } from '../dtos/register.dto';
import { LoginDto } from '../dtos/login.dto';
import { UsersService } from '../../users/services/users.service';
import { AuthService } from '../services/auth.service';
export declare class AuthController {
    private readonly usersService;
    private readonly authService;
    constructor(usersService: UsersService, authService: AuthService);
    register(registerDto: RegisterDto): Promise<{
        id: string;
        email: string;
    }>;
    login(loginDto: LoginDto): Promise<import("../domain/auth-token.type").AuthToken>;
    logout(req: any): Promise<{
        message: string;
    }>;
}
