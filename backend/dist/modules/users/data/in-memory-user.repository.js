"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.InMemoryUserRepository = exports.USER_REPOSITORY = void 0;
const common_1 = require("@nestjs/common");
exports.USER_REPOSITORY = 'USER_REPOSITORY';
let InMemoryUserRepository = class InMemoryUserRepository {
    users = [];
    async save(user) {
        this.users.push(user);
        return user;
    }
    async findByEmail(email) {
        return this.users.find((u) => u.email === email) || null;
    }
    async findById(id) {
        return this.users.find((u) => u.id === id) || null;
    }
    async update(user) {
        const index = this.users.findIndex((u) => u.id === user.id);
        if (index !== -1) {
            this.users[index] = user;
        }
        return user;
    }
};
exports.InMemoryUserRepository = InMemoryUserRepository;
exports.InMemoryUserRepository = InMemoryUserRepository = __decorate([
    (0, common_1.Injectable)()
], InMemoryUserRepository);
//# sourceMappingURL=in-memory-user.repository.js.map