export class UpdateUserDto {
  readonly username?: string;
  readonly email?: string;
  readonly password?: string;
  readonly firstName?: string;
  readonly lastName?: string;
  readonly isActive?: boolean;
  readonly isAdmin?: boolean;
}
