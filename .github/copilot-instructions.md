# GitHub Copilot Instructions for Nx TypeScript Monorepo

## Project Overview

This is an Nx monorepo containing a full-stack TypeScript application with React frontend, NestJS backend services, and proper enterprise-level architecture patterns with shared libraries and strict typing.

## Architecture Structure

### Apps (`apps/`)
- **Frontend Applications**: React + TypeScript with Material-UI, TanStack Query, React Router
- **Backend Services**: NestJS with ORM, database integration, authentication
- **Additional Services**: Microservices and integration services

### Libraries (`libs/`)
- **Types**: Shared TypeScript interfaces and DTOs with class-validator decorators
- **Utilities**: Helper functions with functional programming patterns (lodash/fp)
- **React Components**: Reusable UI components with Material-UI theming
- **Backend Modules**: NestJS decorators, guards, interceptors, and shared services
- **Enums**: Shared constants and enumerations

## NestJS Backend Patterns (Actual Implementation)

### Service-Repository Pattern
Always follow this exact structure as implemented:

```typescript
// Service Pattern
@Injectable()
export class UsersService {
  constructor(
    private readonly azureApiService: AzureApiService,
    private readonly envService: EnvService,
    private readonly usersRepository: UsersRepository
  ) {}

  findAllGroups(accessToken: string): Observable<GroupsResponse> {
    const groupPrefix = this.envService.get('GROUP_PREFIX');
    
    return this.azureApiService
      .get<GroupsResponse>(`me/memberOf?$search="displayName:${groupPrefix}"&$select=displayName`, {
        headers: { Authorization: `Bearer ${accessToken}` }
      })
      .pipe(rxjsMap(response => ({ ...response.data })));
  }
}

// Repository Pattern with Drizzle ORM
@Injectable()
export class UsersRepository {
  constructor(@Inject(DRIZZLE_CLIENT) private readonly drizzleClient: DrizzleClient) {}

  async completedTutorials(userId: string): Promise<string[]> {
    const completedTutorialsRaw = await this.drizzleClient.query.userTutorials.findMany({
      where: eq(userTutorials.userId, userId),
    });
    return map('finishTutorial', completedTutorialsRaw);
  }
}
```

### Controller Pattern with Custom Decorators
Use the existing custom `@Me` decorator pattern:

```typescript
@ApiTags('users')
@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly envService: EnvService
  ) {}

  @Get()
  @UseGuards(RefreshTokenGuard)
  async searchUsers(
    @Me('accessToken') accessToken: string,
    @Query() { search, limit }: SearchParams = {}
  ) {
    return (await this.usersService.searchUsers(accessToken, search, limit)).value;
  }

  @Get('me')
  async me(@Request() req: AuthRequest) {
    return req.user.profile;
  }
}
```

### Custom Parameter Decorator Implementation
Follow this exact pattern for creating parameter decorators:

```typescript
export const Me = createParamDecorator((key: string, ctx: ExecutionContext) => {
  const request = ctx.switchToHttp().getRequest();
  const user = request.user;
  return key ? get(key, user) : user;
});
```

## Drizzle ORM Implementation

### Schema Definition Pattern
Define schemas using pgSchema with proper TypeScript typing:

```typescript
export const authSchema = pgSchema('auth');

export const userTutorials = authSchema.table(
  'userTutorials',
  {
    userId: uuid().notNull(),
    finishTutorial: tutorials().$type<Tutorials>().notNull(),
  },
  (table) => ({
    pk: primaryKey(table.userId, table.finishTutorial),
  })
);

export const users = authSchema.table('users', {
  upn: text().primaryKey(),
  id: uuid().notNull(),
  refreshToken: text().notNull(),
});
```

### Drizzle Module Configuration
Use the ConfigurableModuleClass pattern for Drizzle setup:

```typescript
@Module({
  providers: [
    {
      provide: DRIZZLE_CLIENT,
      useFactory: async (drizzleOptions: DrizzleOptions) => {
        const pgClient = new Client(drizzleOptions);
        await pgClient.connect();
        return drizzle(pgClient, {
          logger: process.env['NODE_ENV'] !== 'production',
          schema,
          casing: 'snake_case',
        });
      },
      inject: [MODULE_OPTIONS_TOKEN],
    },
  ],
  exports: [DRIZZLE_CLIENT],
})
export class DrizzleClientModule extends ConfigurableModuleClass {}
```

### Repository Injection Pattern
Always inject Drizzle client using the DRIZZLE_CLIENT token:

```typescript
@Injectable()
export class UsersRepository {
  constructor(@Inject(DRIZZLE_CLIENT) private readonly drizzleClient: DrizzleClient) {}
}
```

## React Frontend Patterns (Actual Implementation)

### Component Structure
Follow this exact pattern for all React components:

```tsx
// Component Definition
export const ActionButtons: FC<ActionButtonsProps> = ({
  approvalId,
  stepId,
  orderId,
  approverUpdatedData,
  templateTitle,
}) => {
  const classes = useStyles();
  const theme = useTheme();
  const navigate = useNavigate();
  const [openModalLabel, setOpenModalLabel] = useState<string | null>(null);
  
  const { mutateAsync: updateApproval, isPending: isApprovalUpdating } = useUpdateApproval();

  return (
    <Box className={classes.container}>
      {/* Component JSX */}
    </Box>
  );
};

// Types Definition
export type ActionButtonsProps = {
  approvalId: string;
  stepId: string;
  orderId: string;
  approverUpdatedData: any;
  templateTitle: string;
};

// Index Export
import { ActionButtons } from './ActionButtons';
export default ActionButtons;
```

### React Hooks Patterns
Always use functional components with proper hook usage:

```tsx
// State management with useState
const [isSearchWideOpen, setIsSearchWideOpen] = useState(false);
const [drawerWidth, setDrawerWidth] = useState(DEFAULT_SIDEBAR_WIDTH);

// Effects with useEffect
useEffect(() => {
  setIsSidebarOpen(false);
}, [pathname, setIsSidebarOpen]);

// Refs with useRef
const hasRecorded = useRef(false);

// Custom hooks usage
const { data: user } = useCurrUser();
const { mutateAsync: updateApproval, isPending } = useUpdateApproval();
```

### Context Pattern Implementation
Create contexts with proper TypeScript typing:

```tsx
const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider: FC<AuthProviderProps> = ({ children }) => {
  const { data: user } = useCurrUser();
  const { data: userGroups } = useUserGroups();
  
  const { data: userTutorials } = useQuery({
    queryFn: getUserTutorials,
    queryKey: [USER_TUTORIALS_QUERY_KEY],
  });

  const value: AuthContextType = {
    user: user!,
    userGroups: userGroups!,
    userTutorials: userTutorials,
  };

  return (
    <AuthContext.Provider value={value}>
      {!isNil(user) && !isNil(userGroups) && children}
    </AuthContext.Provider>
  );
};

export const useAuthStore = () => {
  const store: AuthContextType | null = useContext(AuthContext);
  if (!store) throw new Error('useAuthStore must be used within an AuthProvider.');
  return store;
};
```

### TanStack Query Hook Patterns
Create custom hooks for API calls:

```typescript
// Simple query hook
export const useDocsByPath = (path: string) =>
  useQuery<{ content: string }>({
    queryKey: [DOCS_BY_PATH_QUERY_KEY, path],
    queryFn: () => getDocsByPath(path),
  });

// Mutation hook with navigation
export const useCreateOrder = () => {
  const navigate = useNavigate();
  return useMutation({
    mutationFn: createOrder,
    onSuccess: ({ orderId }) => navigate(`/orders/${orderId}/status`),
  });
};

// Mutation hook with error handling
export const useUpdateApproval = () => {
  const queryClient = useQueryClient();
  return useMutation<void, AxiosError, { approvalId: string; approval: UpdateApproval }>({
    mutationFn: ({ approvalId, approval }) => updateApproval(approvalId, approval),
    onError: (error) => {
      toast.error(
        error?.response?.status === HttpStatusCode.Unauthorized
          ? 'You are not authorized to update this approval.'
          : 'Something went wrong.'
      );
    },
    onSuccess: async (_, { approvalId }) => {
      await queryClient.invalidateQueries({ queryKey: [APPROVAL_BY_ID_QUERY_KEY, approvalId] });
    },
  });
};
```

### React Query Configuration
Configure QueryClient with proper error handling:

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 0,
      throwOnError: (error) => {
        if ((error as AxiosError)?.response?.status !== HttpStatusCode.Forbidden) return true;
        window.location.href = `${window.location.origin}/login?origin=${encodeURIComponent(
          window.location.href
        )}`;
        return false;
      },
    },
    mutations: { retry: 0 },
  },
});
```

### Form Handling with React Hook Form
Use React Hook Form for complex forms:

```tsx
export const SelfServiceFormPage = () => {
  const methods = useForm();
  const { watch } = useFormContext();
  const formData = watch();

  return (
    <FormProvider {...methods}>
      <form onSubmit={methods.handleSubmit(onSubmit)}>
        <GenericForm templateSpec={templateSpec} step={step} />
      </form>
    </FormProvider>
  );
};

// Field component with controller
export const Checkbox: FC<BackstageBoolProp & BackstageBasicProp & FieldProps> = ({
  name,
  title,
  description,
  disabled,
  required,
  userValue,
}) => {
  const { control } = useFormContext();
  
  const {
    field: { value, ref, ...rest },
    fieldState: { invalid },
  } = useController({
    name,
    control,
    defaultValue: userValue,
    rules: { validate: (value) => !required || !!value },
  });

  return (
    <FormControlLabel
      label={<FieldTitle {...{ title, description, required }} />}
      control={<MuiCheckbox {...rest} checked={!!value} inputRef={ref} />}
    />
  );
};
```

## Nx Workspace Conventions

### Library Structure
- Use workspace-specific prefix for all library imports (e.g., `@your-workspace/`)
- Export everything through `index.ts` barrel files
- Organize types by domain in separate folders (`auth/`, `users/`, `orders/`, etc.)
- Keep shared utilities in `libs/utils` with functional programming style

### Import Patterns
```typescript
// Workspace library imports
import { RuntimeEnv, Tutorials } from '@your-workspace/enums';
import { AuthRequest, SearchParams } from '@your-workspace/types';
import { MarkdownRenderer } from '@your-workspace/react-components';

// External library imports
import { chunk, flatten, join, map, pipe, replace, toLower } from 'lodash/fp';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { FC, useState, useEffect, useRef } from 'react';
```

### Project Organization
```
apps/
  your-app/
    frontend/
      your-client/
        src/
          components/        # Reusable UI components
          views/            # Page-level components  
          services/         # API layer with hooks
          contexts/         # React contexts
          hooks/           # Custom hooks
          utils/           # App-specific utilities
    backend/
      your-service/
        src/
          modules/         # Feature modules
          schemas/         # Database schemas
          guards/          # Authentication guards
          interceptors/    # Request/response interceptors

libs/
  types/                  # Shared TypeScript types
  utils/                  # Shared utilities
  components/             # Shared React components
  backend-modules/        # Shared NestJS modules
  enums/                 # Shared constants
```

## Functional Programming with Lodash/FP

### Lodash/FP Usage Pattern
Always use functional programming style with lodash/fp:

```typescript
// Import specific functions from lodash/fp
import { chunk, flatten, join, map, pipe, replace, toLower } from 'lodash/fp';

// Use pipe for data transformations
const formatGroups = ({ displayName, id }: UserGroups) => ({
  id,
  displayName: removeGroupPrefix(groupPrefix, displayName),
});

// Use map and other FP functions
return map(formatGroups, response.data.value);

// Use filter with predicates
return filter((role) => role.includes(regex), userRoles);

// Curried utility functions
export const createFuzzySearch = <T>() =>
  curry((keys: string[], filterValue: string, rows: T[]) => {
    const terms = split(' ', filterValue);
    return terms.reduceRight((results, term) => matchSorter(results, term, { keys }), rows);
  });
```

## Authentication & Authorization

### Custom Decorator Pattern
Use the `@Me` decorator for extracting user data from request:

```typescript
@Get()
@UseGuards(RefreshTokenGuard)
async searchUsers(
  @Me('accessToken') accessToken: string,
  @Query() { search, limit }: SearchParams = {}
) {
  // Implementation
}

@Get('get-matching-roles')
findMatchingRoles(@Me('runtimeEnv') runtimeEnv: RuntimeEnv, @Req() req: AuthRequest) {
  return this.usersService.findMatchingRoles(runtimeEnv, req.user);
}
```

### AuthRequest Pattern
Always use AuthRequest type for request objects:

```typescript
@Get('me')
async me(@Request() req: AuthRequest) {
  return req.user.profile;
}
```

## TypeScript Types and DTOs

### DTO Pattern with Validation
Use class-validator decorators for DTOs:

```typescript
export class User {
  @ApiProperty()
  @IsString()
  upn!: string;

  @ApiProperty()
  @IsUUID()
  id!: string;

  @ApiProperty()
  @IsString()
  refreshToken!: string;
}
```

### Type Organization
Organize types by domain with barrel exports:

```typescript
// libs/types/src/lib/auth/index.ts
export * from './auth-props';
export * from './user';
export * from './user-session';

// libs/types/src/index.ts
export * from './lib/auth';
export * from './lib/users';
export * from './lib/orders';
```

## Component Architecture Patterns

### React Component Structure
Follow this exact component pattern:

```tsx
// Component Definition
export const MobileView: FC<MobileViewProps> = () => {
  const classes = useStyles();

  return (
    <Box className={classes.page}>
      <Typography variant="h5" textAlign="center">{`（>﹏<）`}</Typography>
      <Typography variant="h5" textAlign="center">
        Oops, sorry!
        <br />
        This website is available from desktop devices only.
      </Typography>
    </Box>
  );
};

// Types Definition
export type MobileViewProps = {};

// Index Export
import { MobileView } from './MobileView';
export default MobileView;
```

### TanStack Query Integration
Use mutations with proper error handling:

```typescript
const { mutate: recordTutorial } = useMutation({
  mutationFn: () => recordUserTutorial(Tutorials.SystemGuide),
  onSuccess: async () => {
    await queryClient.refetchQueries({ queryKey: ['userTutorials'] });
  },
});
```

## Error Handling

### Backend Error Patterns
- Use NestJS built-in HTTP exceptions
- Implement global exception filters
- Log errors with proper context
- Return consistent error responses

```typescript
@Injectable()
export class UsersService {
  async findById(id: string): Promise<User> {
    const user = await this.usersRepository.findById(id);
    
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    
    return user;
  }
}
```

### Frontend Error Patterns
- Use Error Boundaries for component errors
- Implement proper loading states
- Show user-friendly error messages
- Log errors for debugging

## Environment Configuration

### Configuration Management
- Use separate env files for different environments
- Validate environment variables with class-validator
- Use ConfigService for accessing configuration
- Never commit sensitive data

```typescript
export class EnvVars {
  @IsString()
  DATABASE_URL!: string;

  @IsNumber()
  @Min(1)
  @Max(65535)
  PORT!: number;

  @IsEnum(NodeEnv)
  NODE_ENV!: NodeEnv;
}
```

## Performance Considerations

### Backend Optimization
- Use database indexes appropriately
- Implement caching where beneficial
- Use pagination for large datasets
- Apply query optimization

### Frontend Optimization
- Implement code splitting
- Use React.memo for expensive components
- Apply proper key props in lists
- Optimize bundle size

## Security Guidelines

### Authentication Security
- Use secure session configuration
- Implement CSRF protection
- Apply rate limiting
- Validate all inputs

### Data Security
- Sanitize database queries
- Use parameterized queries
- Implement proper authorization checks
- Hash sensitive data

## Deployment Considerations

### Build Configuration
- Use production builds for deployment
- Optimize bundle sizes
- Configure proper environment variables
- Use Docker for containerization

### Monitoring
- Implement health checks
- Add structured logging
- Monitor application metrics
- Set up error tracking

## Code Review Guidelines

### Pull Request Standards
- Write descriptive commit messages
- Include proper documentation
- Add tests for new features
- Follow existing code patterns

### Review Checklist
- TypeScript types are properly defined
- Error handling is implemented
- Tests cover the changes
- Documentation is updated
- Security considerations are addressed

## Common Commands

```bash
# Development
npm run start:dev                    # Start development servers
npm run build                       # Build all projects
npm run test                        # Run all tests
npm run lint                        # Lint all projects

# Nx specific
npx nx graph                        # Show project dependencies
npx nx run-many --target=build      # Build all projects
npx nx run-many --target=test       # Test all projects
npx nx generate @nx/node:library    # Generate new library
```

## Documentation Standards

- Document all public APIs
- Include usage examples
- Maintain README files for each library
- Update documentation with code changes
- Use JSDoc comments for complex functions

## Common Patterns Summary

### Frontend Development
1. **Component Structure**: Named exports with separate types file and index.ts barrel export
2. **State Management**: Use React hooks (useState, useEffect, useRef) with proper TypeScript typing
3. **API Integration**: TanStack Query hooks with proper error handling and loading states
4. **Form Handling**: React Hook Form with useController for complex form validation
5. **Context Usage**: Proper context creation with null checks and error boundaries
6. **Styling**: Material-UI with custom themes and useStyles pattern

### Backend Development
1. **Module Structure**: Controller → Service → Repository pattern with dependency injection
2. **Database**: ORM with proper schema definitions and repository pattern
3. **Authentication**: Custom decorators for user data extraction and proper guard usage
4. **Error Handling**: Consistent HTTP exceptions with proper status codes
5. **Validation**: Class-validator decorators for DTOs and request validation

### Shared Patterns
1. **Type Safety**: Strict TypeScript with proper interfaces and generic constraints
2. **Functional Programming**: Lodash/fp for data transformations and utility functions
3. **Code Organization**: Domain-driven structure with clear separation of concerns
4. **Import Management**: Consistent import ordering and workspace library usage

---

**Remember**: This is an enterprise-level application. Always prioritize code quality, security, and maintainability over quick solutions. Follow established patterns consistently across the codebase.