import { CanActivate, ExecutionContext, Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';

@Injectable()
export class OwnershipGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    if (!user) {
      return false;
    }

    const { id, portfolioId } = request.params;

    // 1. If checking ownership of a portfolio by direct ID
    if (request.route.path.includes('/portfolios/:id') && id) {
      const portfolio = await this.prisma.portfolio.findUnique({
        where: { id },
      });
      if (!portfolio) {
        throw new NotFoundException('Portfolio not found');
      }
      if (portfolio.userId !== user.id) {
        throw new ForbiddenException('You do not own this portfolio');
      }
    }

    // 2. If checking ownership of a parent portfolio by portfolioId param
    if (portfolioId) {
      const portfolio = await this.prisma.portfolio.findUnique({
        where: { id: portfolioId },
      });
      if (!portfolio) {
        throw new NotFoundException('Portfolio not found');
      }
      if (portfolio.userId !== user.id) {
        throw new ForbiddenException('You do not own this portfolio');
      }
    }

    // 3. If checking ownership of an investment by direct ID
    if (request.route.path.includes('/investments/:id') && id) {
      const investment = await this.prisma.investment.findUnique({
        where: { id },
        include: { portfolio: true },
      });
      if (!investment) {
        throw new NotFoundException('Investment not found');
      }
      if (investment.portfolio.userId !== user.id) {
        throw new ForbiddenException('You do not own this investment');
      }
    }

    return true;
  }
}
