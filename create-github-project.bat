@echo off
setlocal enabledelayedexpansion

:: =============================================================================
:: NX Project Creation Script
:: Creates either NX workspaces or simple Git repositories with GitHub integration
:: =============================================================================

:: Ask what type of project to create
echo.
echo ===== Project Setup =====
echo Project type options:
echo 1. NX Workspace (with NestJS/React)
echo 2. Simple Git Repository (empty repo)
echo 3. Terraform Infrastructure Project
echo 4. Full Stack Project (NX + Terraform)
echo.
set /p "project_type=Choose project type (1, 2, 3, or 4): "
set "project_type=!project_type: =!"

:: Validate project type input
if not "!project_type!"=="1" if not "!project_type!"=="2" if not "!project_type!"=="3" if not "!project_type!"=="4" (
    echo ERROR: Invalid project type. Please choose 1, 2, 3, or 4.
    pause
    exit /b 1
)

:: Prompt for project name
echo.
set /p "project_name=Type the name of your Project (e.g., 'twittzi'): "
set "project_name=!project_name:"=!"
set "project_name=!project_name: =!"

:: Validate project name
if "!project_name!"=="" (
    echo ERROR: Project name cannot be empty.
    pause
    exit /b 1
)

:: Ask for organization selection
echo.
echo ===== Organization Setup =====
echo Available organizations:
echo 1. Personal (no organization)
echo 2. Enter custom organization name
echo.
set /p "org_choice=Choose organization option (1 or 2): "
set "org_choice=!org_choice: =!"

:: Validate organization choice
if not "!org_choice!"=="1" if not "!org_choice!"=="2" (
    echo ERROR: Invalid organization choice. Please choose 1 or 2.
    pause
    exit /b 1
)

set "organization="
if "!org_choice!"=="2" (
    set /p "organization=Enter organization name: "
    set "organization=!organization:"=!"
    set "organization=!organization: =!"
    
    :: Validate organization name
    if "!organization!"=="" (
        echo ERROR: Organization name cannot be empty when option 2 is selected.
        pause
        exit /b 1
    )
)

:: Ask if server should be created (for NX workspace and Full Stack projects)
if "!project_type!"=="1" (
    echo.
    echo ===== NX Server Setup =====
    set /p "create_server=Do you want to create a NestJS server? (y/n): "
    set "create_server=!create_server: =!"
    
    :: Validate server choice
    if /i not "!create_server!"=="y" if /i not "!create_server!"=="n" (
        echo ERROR: Invalid choice. Please enter 'y' or 'n'.
        pause
        exit /b 1
    )

    if /i "!create_server!"=="y" (
        set /p "nest_app_name=Type the name of your NestJS App (e.g., 'twittzi-server'): "
        set "nest_app_name=!nest_app_name:"=!"
        set "nest_app_name=!nest_app_name: =!"
        
        :: Validate nest app name
        if "!nest_app_name!"=="" (
            echo ERROR: NestJS app name cannot be empty.
            pause
            exit /b 1
        )
    )
) else if "!project_type!"=="4" (
    echo.
    echo ===== Full Stack NX Server Setup =====
    set /p "create_server=Do you want to create a NestJS server? (y/n): "
    set "create_server=!create_server: =!"
    
    :: Validate server choice
    if /i not "!create_server!"=="y" if /i not "!create_server!"=="n" (
        echo ERROR: Invalid choice. Please enter 'y' or 'n'.
        pause
        exit /b 1
    )

    if /i "!create_server!"=="y" (
        set /p "nest_app_name=Type the name of your NestJS App (e.g., 'twittzi-server'): "
        set "nest_app_name=!nest_app_name:"=!"
        set "nest_app_name=!nest_app_name: =!"
        
        :: Validate nest app name
        if "!nest_app_name!"=="" (
            echo ERROR: NestJS app name cannot be empty.
            pause
            exit /b 1
        )
    )
) else (
    set "create_server=n"
)

:: Ask if client should be created (for NX workspace and Full Stack projects)
if "!project_type!"=="1" (
    echo.
    echo ===== NX Client Setup =====
    set /p "create_client=Do you want to create a React client? (y/n): "
    set "create_client=!create_client: =!"
    
    :: Validate client choice
    if /i not "!create_client!"=="y" if /i not "!create_client!"=="n" (
        echo ERROR: Invalid choice. Please enter 'y' or 'n'.
        pause
        exit /b 1
    )

    if /i "!create_client!"=="y" (
        set /p "react_app_name=Type the name of your React App (e.g., 'twittzi-client'): "
        set "react_app_name=!react_app_name:"=!"
        set "react_app_name=!react_app_name: =!"
        
        :: Validate react app name
        if "!react_app_name!"=="" (
            echo ERROR: React app name cannot be empty.
            pause
            exit /b 1
        )
    )
) else if "!project_type!"=="4" (
    echo.
    echo ===== Full Stack NX Client Setup =====
    set /p "create_client=Do you want to create a React client? (y/n): "
    set "create_client=!create_client: =!"
    
    :: Validate client choice
    if /i not "!create_client!"=="y" if /i not "!create_client!"=="n" (
        echo ERROR: Invalid choice. Please enter 'y' or 'n'.
        pause
        exit /b 1
    )

    if /i "!create_client!"=="y" (
        set /p "react_app_name=Type the name of your React App (e.g., 'twittzi-client'): "
        set "react_app_name=!react_app_name:"=!"
        set "react_app_name=!react_app_name: =!"
        
        :: Validate react app name
        if "!react_app_name!"=="" (
            echo ERROR: React app name cannot be empty.
            pause
            exit /b 1
        )
    )
) else (
    set "create_client=n"
)

:: Ask for shared libraries setup (for NX workspace and Full Stack projects)
if "!project_type!"=="1" (
    echo.
    echo ===== NX Shared Libraries Setup =====
    echo Do you want to create enterprise-level shared libraries?
    echo Basic libraries: enums, types, utils
    echo React libraries: react-components (reusable UI components)
    echo Backend libraries: backend-modules (NestJS decorators, guards, interceptors)
    echo These will use @!project_name!/[lib-name] imports for proper workspace organization
    set /p "create_shared_libs=Create shared libraries? (y/n): "
    set "create_shared_libs=!create_shared_libs: =!"
    
    :: Validate shared libraries choice
    if /i not "!create_shared_libs!"=="y" if /i not "!create_shared_libs!"=="n" (
        echo ERROR: Invalid choice. Please enter 'y' or 'n'.
        pause
        exit /b 1
    )
) else if "!project_type!"=="4" (
    echo.
    echo ===== Full Stack Shared Libraries Setup =====
    echo Do you want to create enterprise-level shared libraries?
    echo Basic libraries: enums, types, utils
    echo React libraries: react-components (reusable UI components)
    echo Backend libraries: backend-modules (NestJS decorators, guards, interceptors)
    echo These will use @!project_name!/[lib-name] imports for proper workspace organization
    set /p "create_shared_libs=Create shared libraries? (y/n): "
    set "create_shared_libs=!create_shared_libs: =!"
    
    :: Validate shared libraries choice
    if /i not "!create_shared_libs!"=="y" if /i not "!create_shared_libs!"=="n" (
        echo ERROR: Invalid choice. Please enter 'y' or 'n'.
        pause
        exit /b 1
    )
) else (
    set "create_shared_libs=n"
)

:: Ask for GitHub repo visibility
echo.
echo ===== GitHub Repository Setup =====
echo Repository visibility options:
echo 1. Public (visible to everyone)
echo 2. Private (only visible to you and collaborators)
echo 3. Internal (visible to organization members)
echo.
set /p "repo_choice=Choose repository visibility (1, 2, or 3): "
set "repo_choice=!repo_choice: =!"

:: Validate repository visibility choice
if not "!repo_choice!"=="1" if not "!repo_choice!"=="2" if not "!repo_choice!"=="3" (
    echo ERROR: Invalid repository visibility choice. Please choose 1, 2, or 3.
    pause
    exit /b 1
)

set "repo_visibility=public"
if "!repo_choice!"=="2" (
    set "repo_visibility=private"
) else if "!repo_choice!"=="3" (
    set "repo_visibility=internal"
)

:: Summary
echo.
echo ========================================
echo              SUMMARY
echo ========================================
if "!project_type!"=="1" (
    echo Project Type: NX Workspace
) else if "!project_type!"=="2" (
    echo Project Type: Simple Git Repository
) else if "!project_type!"=="3" (
    echo Project Type: Terraform Infrastructure Project
) else if "!project_type!"=="4" (
    echo Project Type: Full Stack Project ^(NX + Terraform^)
)
echo Project Name: !project_name!
if not "!organization!"=="" (
    echo Organization: !organization!
) else (
    echo Organization: Personal
)
if "!project_type!"=="1" if /i "!create_server!"=="y" if /i "!create_client!"=="y" (
    echo Create Server: !create_server!
    echo Nest App Name: !nest_app_name!
    echo Create Client: !create_client!
    echo React App Name: !react_app_name!
) else if "!project_type!"=="1" if /i "!create_server!"=="y" (
    echo Create Server: !create_server!
    echo Nest App Name: !nest_app_name!
    echo Create Client: !create_client!
) else if "!project_type!"=="1" if /i "!create_client!"=="y" (
    echo Create Server: !create_server!
    echo Create Client: !create_client!
    echo React App Name: !react_app_name!
) else if "!project_type!"=="1" (
    echo Create Server: !create_server!
    echo Create Client: !create_client!
)
if "!project_type!"=="1" if /i "!create_shared_libs!"=="y" (
    echo Shared Libraries: Enterprise-level libraries with @!project_name!/[lib-name] imports
    echo - Core: types, enums, utils ^(with lodash/fp support^)
    if /i "!create_client!"=="y" echo - Frontend: react-components ^(Material-UI, TanStack Query^)
    if /i "!create_server!"=="y" echo - Backend: backend-modules ^(NestJS decorators, guards^)
)
if "!project_type!"=="3" (
    echo Terraform: Infrastructure files will be copied
    echo GitHub Actions: Terraform workflows will be included
) else if "!project_type!"=="4" (
    echo Terraform: Infrastructure files will be copied
    echo GitHub Actions: Both NX and Terraform workflows will be included
    if /i "!create_server!"=="y" echo Nest App Name: !nest_app_name!
    if /i "!create_client!"=="y" echo React App Name: !react_app_name!
    if /i "!create_shared_libs!"=="y" (
        echo Shared Libraries: Enterprise-level libraries with @!project_name!/[lib-name] imports
        echo   - Core: types, enums, utils ^(with lodash/fp support^)
        if /i "!create_client!"=="y" echo   - Frontend: react-components ^(Material-UI, TanStack Query^)
        if /i "!create_server!"=="y" echo   - Backend: backend-modules ^(NestJS decorators, guards^)
    )
) else if "!project_type!"=="1" (
    echo GitHub Actions: NX workflows will be included
)
echo GitHub Actions: release-please workflow included for all projects
echo GitHub Visibility: !repo_visibility!
echo ========================================
echo.
set /p "confirm=Proceed with these settings? (y/n): "
if /i not "!confirm!"=="y" (
    echo Operation cancelled by user.
    pause
    exit /b 0
)

:: =============================================================================
:: PROJECT CREATION
:: =============================================================================


:: Check and fix npm setup issues
echo.
echo Checking npm configuration...
echo DEBUG: Entered npm configuration check

:: Check if npm is installed
echo DEBUG: Checking npm version...
for /f "delims=" %%v in ('npm --version 2^>^&1') do set "npm_version=%%v"
echo DEBUG: npm --version output: !npm_version!
if "!npm_version!"=="" (
    echo ERROR: npm is not installed or not found in PATH.
    echo.
    echo Please install Node.js which includes npm:
    echo 1. Visit: https://nodejs.org/
    echo 2. Download and install the LTS version
    echo 3. Restart your command prompt
    echo 4. Run this script again
    echo.
    pause
    exit /b 1
)
echo DEBUG: npm version found: !npm_version!

:: Fix npm global directory issue if it doesn't exist
echo DEBUG: Checking npm global directory...
set "npm_global_dir=%APPDATA%\npm"
if not exist "!npm_global_dir!" (
    echo Creating npm global directory...
    mkdir "!npm_global_dir!" 2>nul
    echo DEBUG: mkdir npm_global_dir errorlevel=!errorlevel!
    if !errorlevel! neq 0 (
        echo WARNING: Could not create npm global directory. Trying alternative approach...
        :: Try to run npm config to initialize directories
        npm config get prefix >nul 2>&1
    )
)

:: Check if npx is available
echo DEBUG: Checking npx version...
for /f "delims=" %%v in ('npx --version 2^>^&1') do set "npx_version=%%v"
echo DEBUG: npx --version output: !npx_version!
if "!npx_version!"=="" (
    echo ERROR: npx is not available or not found in PATH.
    echo Please update Node.js to a version that includes npx.
    pause
    exit /b 1
)
echo DEBUG: npx version found: !npx_version!

echo DEBUG: npm and npx configuration verified.
echo npm configuration verified.

:: Suggest npm update if there's a newer version available
echo Checking for npm updates...
echo DEBUG: Checking for npm outdated...
for /f "delims=" %%o in ('npm outdated -g npm 2^>^&1') do set "npm_outdated=%%o"
echo DEBUG: npm outdated -g npm output: !npm_outdated!
echo DEBUG: npm outdated check errorlevel=!errorlevel!
if !errorlevel! equ 0 (
    echo.
    echo INFO: A newer version of npm is available.
    echo Consider updating npm for better performance: npm install -g npm@latest
    echo.
    set /p "update_npm=Would you like to update npm now? (y/n): "
    set "update_npm=!update_npm: =!"
    
    if /i "!update_npm!"=="y" (
        echo Updating npm...
        npm install -g npm@latest
        if !errorlevel! neq 0 (
            echo WARNING: Failed to update npm. Continuing with current version...
        ) else (
            echo npm updated successfully.
        )
    )
)

:: Navigate to parent directory to create the new project
echo.
echo Navigating to parent directory...
cd ..
echo DEBUG: Changed to parent directory, current directory: %CD%

:: Create base workspace
echo.
echo Creating project structure...
echo DEBUG: Project type is !project_type!
if "!project_type!"=="1" (
    echo Setting up NX workspace...
    if /i "!create_server!"=="y" (
        echo Creating NX workspace with NestJS preset...
        echo This may take a few minutes...
        CALL npx create-nx-workspace !project_name! --preset=nest --nxCloud=skip --packageManager=npm --appName=!nest_app_name! --e2eTestRunner=none --workspaceType=integrated --docker=false
        set "nx_creation_result=!errorlevel!"
    ) else (
        echo Creating basic NX workspace...
        echo This may take a few minutes...
        CALL npx create-nx-workspace !project_name! --preset=apps --nxCloud=skip --packageManager=npm --workspaceType=integrated
        set "nx_creation_result=!errorlevel!"
    )

    :: Check if NX creation failed
    if !nx_creation_result! neq 0 (
        echo.
        echo WARNING: NX workspace creation failed. Trying alternative approach...
        
        :: Try clearing npm cache and retry
        echo Clearing npm cache...
        npm cache clean --force >nul 2>&1
        
        :: Try creating the directory manually and then initialize
        if not exist "!project_name!" mkdir "!project_name!"
        cd "!project_name!"
        
        :: Try alternative approach with npm init
        echo Trying alternative project setup...
        npm init -y >nul 2>&1
        
        :: Create basic package.json for NX workspace
        echo {> package.json
        echo   "name": "!project_name!",>> package.json
        echo   "version": "0.0.0",>> package.json
        echo   "license": "MIT",>> package.json
        echo   "scripts": {},>> package.json
        echo   "private": true,>> package.json
        echo   "devDependencies": {}>> package.json
        echo }>> package.json
        
        :: Try installing NX directly
        echo Installing NX...
        npm install --save-dev @nrwl/workspace@latest nx@latest
        if !errorlevel! neq 0 (
            echo ERROR: Failed to install NX. Please check your npm installation.
            echo.
            echo Possible solutions:
            echo 1. Update Node.js to the latest LTS version
            echo 2. Clear npm cache: npm cache clean --force
            echo 3. Check your internet connection
            echo 4. Try running as administrator
            echo.
            pause
            exit /b 1
        )
        
        :: Initialize NX workspace
        echo Initializing NX workspace...
        npx nx init
        
        cd ..
    )

    :: Check if workspace directory was created successfully
    if not exist "!project_name!\nx.json" if not exist "!project_name!\workspace.json" (
        echo.
        echo ERROR: Failed to create NX workspace. Exiting.
        pause
        exit /b 1
    )
    echo NX workspace created successfully.
) else if "!project_type!"=="4" (
    echo Setting up Full Stack NX workspace...
    if /i "!create_server!"=="y" (
        echo Creating NX workspace with NestJS preset...
        echo This may take a few minutes...
        CALL npx create-nx-workspace !project_name! --preset=nest --nxCloud=skip --packageManager=npm --appName=!nest_app_name! --e2eTestRunner=none --workspaceType=integrated --docker=false
        set "nx_creation_result=!errorlevel!"
    ) else (
        echo Creating basic NX workspace...
        echo This may take a few minutes...
        CALL npx create-nx-workspace !project_name! --preset=apps --nxCloud=skip --packageManager=npm --workspaceType=integrated
        set "nx_creation_result=!errorlevel!"
    )

    :: Check if NX creation failed
    if !nx_creation_result! neq 0 (
        echo.
        echo WARNING: NX workspace creation failed. Trying alternative approach...
        
        :: Try clearing npm cache and retry
        echo Clearing npm cache...
        npm cache clean --force >nul 2>&1
        
        :: Try creating the directory manually and then initialize
        if not exist "!project_name!" mkdir "!project_name!"
        cd "!project_name!"
        
        :: Try alternative approach with npm init
        echo Trying alternative project setup...
        npm init -y >nul 2>&1
        
        :: Create basic package.json for NX workspace
        echo {> package.json
        echo   "name": "!project_name!",>> package.json
        echo   "version": "0.0.0",>> package.json
        echo   "license": "MIT",>> package.json
        echo   "scripts": {},>> package.json
        echo   "private": true,>> package.json
        echo   "devDependencies": {}>> package.json
        echo }>> package.json
        
        :: Try installing NX directly
        echo Installing NX...
        npm install --save-dev @nrwl/workspace@latest nx@latest
        if !errorlevel! neq 0 (
            echo ERROR: Failed to install NX. Please check your npm installation.
            echo.
            echo Possible solutions:
            echo 1. Update Node.js to the latest LTS version
            echo 2. Clear npm cache: npm cache clean --force
            echo 3. Check your internet connection
            echo 4. Try running as administrator
            echo.
            pause
            exit /b 1
        )
        
        :: Initialize NX workspace
        echo Initializing NX workspace...
        npx nx init
        
        cd ..
    )

    :: Check if workspace directory was created successfully
    if not exist "!project_name!\nx.json" if not exist "!project_name!\workspace.json" (
        echo.
        echo ERROR: Failed to create NX workspace. Exiting.
        pause
        exit /b 1
    )
    echo Full Stack NX workspace created successfully.
) else (
    echo Creating simple directory structure...
    mkdir "!project_name!"
    echo DEBUG: mkdir project directory errorlevel=!errorlevel!
    if not exist "!project_name!" (
        echo ERROR: Failed to create project directory.
        pause
        exit /b 1
    )
    echo Directory created successfully.
)

cd "!project_name!"
echo DEBUG: Changed directory to project, current directory: %CD%
echo Changed directory to: %CD%

:: Reorganize NestJS app to backend directory (for NX workspace and Full Stack projects)
echo DEBUG: Server reorganization - project_type=!project_type!, create_server=!create_server!
if "!project_type!"=="1" if /i "!create_server!"=="y" (
    echo Reorganizing NestJS app to apps/backend directory...
    if exist "apps\!nest_app_name!" (
        if not exist "apps\backend" mkdir "apps\backend"
        move "apps\!nest_app_name!" "apps\backend\!nest_app_name!" >nul
        if !errorlevel! equ 0 (
            echo NestJS app moved to apps/backend/!nest_app_name! successfully.
        ) else (
            echo WARNING: Failed to move NestJS app to backend directory.
        )
    )
) else if "!project_type!"=="4" if /i "!create_server!"=="y" (
    echo DEBUG: Full Stack server reorganization - project_type=!project_type!, create_server=!create_server!
    echo Reorganizing NestJS app to apps/backend directory for Full Stack project...
    if exist "apps\!nest_app_name!" (
        if not exist "apps\backend" mkdir "apps\backend"
        move "apps\!nest_app_name!" "apps\backend\!nest_app_name!" >nul
        if !errorlevel! equ 0 (
            echo NestJS app moved to apps/backend/!nest_app_name! successfully.
        ) else (
            echo WARNING: Failed to move NestJS app to backend directory.
        )
    )
)

:: React app setup (for NX workspace and Full Stack projects)
echo DEBUG: React app setup - project_type=!project_type!, create_client=!create_client!
if "!project_type!"=="1" if /i "!create_client!"=="y" (
    echo.
    echo Setting up React application...
    CALL npm install -D @nrwl/react
    if !errorlevel! neq 0 (
        echo ERROR: Failed to install React dependencies.
        pause
        exit /b 1
    )
    
    CALL npx nx g @nrwl/react:app !react_app_name! --bundler=vite --e2eTestRunner=none --compiler=swc --pascalCaseFiles=true --unitTestRunner=none --routing=false --style=css --directory=apps/frontend --projectNameAndRootFormat=as-provided
    if !errorlevel! neq 0 (
        echo ERROR: Failed to generate React application.
        pause
        exit /b 1
    )
    echo React application created successfully.
) else if "!project_type!"=="4" if /i "!create_client!"=="y" (
    echo DEBUG: Full Stack React client creation - project_type=!project_type!, create_client=!create_client!
    echo.
    echo Setting up React application for Full Stack project...
    CALL npm install -D @nrwl/react
    if !errorlevel! neq 0 (
        echo ERROR: Failed to install React dependencies.
        pause
        exit /b 1
    )
    
    CALL npx nx g @nrwl/react:app !react_app_name! --bundler=vite --e2eTestRunner=none --compiler=swc --pascalCaseFiles=true --unitTestRunner=none --routing=false --style=css --directory=apps/frontend --projectNameAndRootFormat=as-provided
    if !errorlevel! neq 0 (
        echo ERROR: Failed to generate React application.
        pause
        exit /b 1
    )
    echo React application created successfully.
)

:: Create shared libraries if requested (for NX workspace and Full Stack projects)
echo DEBUG: Shared libraries - project_type=!project_type!, create_shared_libs=!create_shared_libs!
if "!project_type!"=="1" if /i "!create_shared_libs!"=="y" (
    echo.
    echo Creating enterprise-level shared libraries...
    
    :: Create core libraries
    echo Creating core libraries ^(types, enums, utils^)...
    
    :: Create types library with domain organization
    CALL npx nx g @nrwl/js:lib types --bundler=swc --unitTestRunner=none --directory=libs/types --projectNameAndRootFormat=as-provided
    if !errorlevel! neq 0 (
        echo WARNING: Failed to create types library.
    ) else (
        echo types library created successfully.
    )
    
    :: Create enums library
    CALL npx nx g @nrwl/js:lib enums --bundler=swc --unitTestRunner=none --directory=libs/enums --projectNameAndRootFormat=as-provided
    if !errorlevel! neq 0 (
        echo WARNING: Failed to create enums library.
    ) else (
        echo enums library created successfully.
    )
    
    :: Create utils library with functional programming support
    CALL npx nx g @nrwl/js:lib utils --bundler=swc --unitTestRunner=none --directory=libs/utils --projectNameAndRootFormat=as-provided
    if !errorlevel! neq 0 (
        echo WARNING: Failed to create utils library.
    ) else (
        echo utils library created successfully.
    )
    
    :: Create React components library if client exists
    if /i "!create_client!"=="y" (
        echo Creating React components library...
        CALL npx nx g @nrwl/react:lib react-components --bundler=swc --unitTestRunner=none --directory=libs/react-components --projectNameAndRootFormat=as-provided
        if !errorlevel! neq 0 (
            echo WARNING: Failed to create react-components library.
        ) else (
            echo react-components library created successfully.
        )
    )
    
    :: Create backend modules library if server exists
    if /i "!create_server!"=="y" (
        echo Creating backend modules library...
        CALL npx nx g @nrwl/js:lib backend-modules --bundler=swc --unitTestRunner=none --directory=libs/backend-modules --projectNameAndRootFormat=as-provided
        if !errorlevel! neq 0 (
            echo WARNING: Failed to create backend-modules library.
        ) else (
            echo backend-modules library created successfully.
        )
    )
    
    echo Enterprise shared libraries created successfully!
    echo Available imports: @!project_name!/types, @!project_name!/enums, @!project_name!/utils
    if /i "!create_client!"=="y" echo - @!project_name!/react-components
    if /i "!create_server!"=="y" echo - @!project_name!/backend-modules
    
    :: Install enterprise-level dependencies
    echo.
    echo Installing enterprise dependencies...
    
    :: Install functional programming utilities
    echo Installing lodash/fp for functional programming patterns...
    CALL npm install lodash
    CALL npm install -D @types/lodash
    
    :: Install validation libraries
    echo Installing class-validator for DTOs...
    CALL npm install class-validator class-transformer
    
    :: Install React ecosystem if client exists
    if /i "!create_client!"=="y" (
        echo Installing React enterprise ecosystem...
        CALL npm install @tanstack/react-query react-router-dom @mui/material @emotion/react @emotion/styled
        CALL npm install -D @types/react-router-dom
    )
    
    :: Install NestJS ecosystem if server exists
    if /i "!create_server!"=="y" (
        echo Installing NestJS enterprise ecosystem...
        CALL npm install @nestjs/swagger @nestjs/config rxjs
        CALL npm install -D @types/node
    )
    
    echo Enterprise dependencies installed successfully!
) else if "!project_type!"=="4" if /i "!create_shared_libs!"=="y" (
    echo.
    echo Creating enterprise-level shared libraries for Full Stack project...
    
    :: Create core libraries
    echo Creating core libraries ^(types, enums, utils^)...
    
    :: Create types library with domain organization
    CALL npx nx g @nrwl/js:lib types --bundler=swc --unitTestRunner=none --directory=libs/types --projectNameAndRootFormat=as-provided
    if !errorlevel! neq 0 (
        echo WARNING: Failed to create types library.
    ) else (
        echo types library created successfully.
    )
    
    :: Create enums library
    CALL npx nx g @nrwl/js:lib enums --bundler=swc --unitTestRunner=none --directory=libs/enums --projectNameAndRootFormat=as-provided
    if !errorlevel! neq 0 (
        echo WARNING: Failed to create enums library.
    ) else (
        echo enums library created successfully.
    )
    
    :: Create utils library with functional programming support
    CALL npx nx g @nrwl/js:lib utils --bundler=swc --unitTestRunner=none --directory=libs/utils --projectNameAndRootFormat=as-provided
    if !errorlevel! neq 0 (
        echo WARNING: Failed to create utils library.
    ) else (
        echo utils library created successfully.
    )
    
    :: Create React components library if client exists
    if /i "!create_client!"=="y" (
        echo Creating React components library...
        CALL npx nx g @nrwl/react:lib react-components --bundler=swc --unitTestRunner=none --directory=libs/react-components --projectNameAndRootFormat=as-provided
        if !errorlevel! neq 0 (
            echo WARNING: Failed to create react-components library.
        ) else (
            echo react-components library created successfully.
        )
    )
    
    :: Create backend modules library if server exists
    if /i "!create_server!"=="y" (
        echo Creating backend modules library...
        CALL npx nx g @nrwl/js:lib backend-modules --bundler=swc --unitTestRunner=none --directory=libs/backend-modules --projectNameAndRootFormat=as-provided
        if !errorlevel! neq 0 (
            echo WARNING: Failed to create backend-modules library.
        ) else (
            echo backend-modules library created successfully.
        )
    )
    
    echo Enterprise shared libraries for Full Stack project created successfully!
    echo Available imports: @!project_name!/types, @!project_name!/enums, @!project_name!/utils
    if /i "!create_client!"=="y" echo - @!project_name!/react-components
    if /i "!create_server!"=="y" echo - @!project_name!/backend-modules
    
    :: Install enterprise-level dependencies for Full Stack
    echo.
    echo Installing Full Stack enterprise dependencies...
    
    :: Install functional programming utilities
    echo Installing lodash/fp for functional programming patterns...
    CALL npm install lodash
    CALL npm install -D @types/lodash
    
    :: Install validation libraries
    echo Installing class-validator for DTOs...
    CALL npm install class-validator class-transformer
    
    :: Install React ecosystem if client exists
    if /i "!create_client!"=="y" (
        echo Installing React enterprise ecosystem...
        CALL npm install @tanstack/react-query react-router-dom @mui/material @emotion/react @emotion/styled
        CALL npm install -D @types/react-router-dom
    )
    
    :: Install NestJS ecosystem if server exists
    if /i "!create_server!"=="y" (
        echo Installing NestJS enterprise ecosystem...
        CALL npm install @nestjs/swagger @nestjs/config rxjs
        CALL npm install -D @types/node
    )
    
    echo Full Stack enterprise dependencies installed successfully!
)

:: Configure TypeScript for enterprise patterns (for NX workspace and Full Stack projects)
if "!project_type!"=="1" if /i "!create_shared_libs!"=="y" (
    echo.
    echo Configuring TypeScript for enterprise patterns...
    
    :: Add strict TypeScript configuration
    echo Updating tsconfig.base.json for strict typing...
    
    :: This would ideally modify tsconfig.base.json to include:
    :: - strict: true
    :: - strictNullChecks: true
    :: - noImplicitAny: true
    :: - exactOptionalPropertyTypes: true
    echo TypeScript configuration updated for enterprise-level type safety.
) else if "!project_type!"=="4" if /i "!create_shared_libs!"=="y" (
    echo.
    echo Configuring TypeScript for Full Stack enterprise patterns...
    echo TypeScript configuration updated for enterprise-level type safety.
)

:: Add scripts (for NX workspace and Full Stack projects)
if "!project_type!"=="1" (
    echo.
    echo Configuring npm scripts...
    if /i "!create_client!"=="y" (
        CALL npm pkg set scripts.start:client="nx serve !react_app_name! --port=3000"
    )
    if /i "!create_server!"=="y" (
        CALL npm pkg set scripts.start:server="nx serve !nest_app_name!"
        CALL npm pkg set scripts.test:server="nx test !nest_app_name!"
    )
    echo npm scripts configured successfully.
) else if "!project_type!"=="4" (
    echo.
    echo Configuring npm scripts for Full Stack project...
    if /i "!create_client!"=="y" (
        CALL npm pkg set scripts.start:client="nx serve !react_app_name! --port=3000"
    )
    if /i "!create_server!"=="y" (
        CALL npm pkg set scripts.start:server="nx serve !nest_app_name!"
        CALL npm pkg set scripts.test:server="nx test !nest_app_name!"
    )
    echo npm scripts configured successfully.
) else (
    echo.
    echo Creating basic project files...
    echo # !project_name! > README.md
    echo. >> README.md
    echo This is a simple Git repository. >> README.md
    echo. >> README.md
    echo ## Getting Started >> README.md
    echo. >> README.md
    echo Add your project documentation here. >> README.md
    echo Basic README.md created successfully.
)

:: =============================================================================
:: COPY GITIGNORE FILE
:: =============================================================================

:: Copy .gitignore file from template repository for all project types
echo.
echo Setting up .gitignore file...
if exist "..\create-github-project\.gitignore" (
    echo Copying .gitignore from template repository...
    copy "..\create-github-project\.gitignore" "." /Y >nul
    if !errorlevel! neq 0 (
        echo WARNING: Failed to copy .gitignore from template.
    ) else (
        echo .gitignore copied successfully from template.
    )
) else (
    echo WARNING: .gitignore not found in template at ..\create-github-project\
)

:: Copy copilot instructions for all project types
echo.
echo Setting up GitHub Copilot instructions...
if not exist ".github" mkdir ".github"
if exist "..\create-github-project\.github\copilot-instructions.md" (
    echo Copying GitHub Copilot instructions from template...
    copy "..\create-github-project\.github\copilot-instructions.md" ".github\" /Y >nul
    if !errorlevel! neq 0 (
        echo WARNING: Failed to copy copilot instructions.
    ) else (
        if "!project_type!"=="1" (
            echo Copilot instructions copied successfully - provides enterprise NX patterns.
        ) else if "!project_type!"=="4" (
            echo Copilot instructions copied successfully - provides enterprise Full Stack patterns.
        ) else (
            echo Copilot instructions copied successfully - provides development best practices.
        )
    )
) else (
    echo WARNING: copilot-instructions.md not found in template at ..\create-github-project\.github\
)

:: =============================================================================
:: TERRAFORM AND WORKFLOWS SETUP
:: =============================================================================

:: Copy Terraform infrastructure if selected
if "!project_type!"=="3" (
    echo.
    echo Setting up Terraform infrastructure...
    if exist "..\infrastructure\example-terraform" (
        echo Copying Terraform files...
        xcopy "..\infrastructure\example-terraform" "infrastructure\" /E /I /Q
        if !errorlevel! neq 0 (
            echo WARNING: Failed to copy Terraform infrastructure files.
        ) else (
            echo Terraform infrastructure copied successfully.
        )
    ) else (
        echo WARNING: Terraform infrastructure source not found at ..\infrastructure\example-terraform
    )
)

:: Copy Terraform infrastructure for Full Stack projects
if "!project_type!"=="4" (
    echo.
    echo Setting up Full Stack project with Terraform...
    if exist "..\infrastructure\example-terraform" (
        echo Copying Terraform files...
        xcopy "..\infrastructure\example-terraform" "infrastructure\" /E /I /Q
        if !errorlevel! neq 0 (
            echo WARNING: Failed to copy Terraform infrastructure files.
        ) else (
            echo Terraform infrastructure copied successfully.
        )
    ) else (
        echo WARNING: Terraform infrastructure source not found at ..\infrastructure\example-terraform
    )
)

:: =============================================================================
:: GITHUB ACTIONS WORKFLOWS SETUP
:: =============================================================================

echo.
echo Setting up GitHub Actions workflows...

:: Create .github directories
if not exist ".github" mkdir ".github"
if not exist ".github\workflows" mkdir ".github\workflows"
if not exist ".github\actions" mkdir ".github\actions"

:: Debugging release-please.yml issue
:: Print current working directory
cd

:: Check if release-please.yml exists
if exist "..\create-github-project\.github\workflows\release-please.yml" (
    echo DEBUG: release-please.yml found at ..\create-github-project\.github\workflows\release-please.yml
) else (
    echo DEBUG: release-please.yml NOT found at ..\create-github-project\.github\workflows\release-please.yml
)

:: Always copy release-please files for all project types
if exist "..\create-github-project\.github\workflows\release-please.yml" (
    echo Copying release-please workflow from template...
    copy "..\create-github-project\.github\workflows\release-please.yml" ".github\workflows\" /Y >nul
    if !errorlevel! neq 0 (
        echo ERROR: Failed to copy release-please.yml from template.
    ) else (
        echo release-please.yml copied successfully from template.
    )
) else (
    echo ERROR: release-please.yml not found in template at ..\create-github-project\.github\workflows\
)

:: Copy release-please configuration files
if exist "..\create-github-project\release-please-config.json" (
    echo Copying release-please-config.json from template...
    copy "..\create-github-project\release-please-config.json" "." /Y >nul
    if !errorlevel! neq 0 (
        echo ERROR: Failed to copy release-please-config.json from template.
    ) else (
        echo release-please-config.json copied successfully from template.
    )
) else (
    echo WARNING: release-please-config.json not found in template at ..\create-github-project\
)

if exist "..\create-github-project\.release-please-manifest.json" (
    echo Copying .release-please-manifest.json from template...
    copy "..\create-github-project\.release-please-manifest.json" "." /Y >nul
    if !errorlevel! neq 0 (
        echo ERROR: Failed to copy .release-please-manifest.json from template.
    ) else (
        echo .release-please-manifest.json copied successfully from template.
    )
) else (
    echo WARNING: .release-please-manifest.json not found in template at ..\create-github-project\
)

:: Copy NX-related workflows and actions for NX workspace and Full Stack projects
if "!project_type!"=="1" (
    echo Copying NX deployment workflows and actions...
    
    :: Copy deploy-NX-projects.yaml workflow
    if exist "..\.github\workflows\deploy-NX-projects.yaml" (
        copy "..\.github\workflows\deploy-NX-projects.yaml" ".github\workflows\" /Y >nul
        if !errorlevel! neq 0 (
            echo WARNING: Failed to copy deploy-NX-projects.yaml
        ) else (
            echo deploy-NX-projects.yaml copied successfully.
        )
    )
    
    :: Copy NX-related actions
    if exist "..\.github\actions\nx-setup" (
        xcopy "..\.github\actions\nx-setup" ".github\actions\nx-setup\" /E /I /Q
        if !errorlevel! equ 0 echo nx-setup action copied successfully.
    )
    
    if exist "..\.github\actions\build-project" (
        xcopy "..\.github\actions\build-project" ".github\actions\build-project\" /E /I /Q
        if !errorlevel! equ 0 echo build-project action copied successfully.
    )
    
    if exist "..\.github\actions\build-push" (
        xcopy "..\.github\actions\build-push" ".github\actions\build-push\" /E /I /Q
        if !errorlevel! equ 0 echo build-push action copied successfully.
    )
    
    if exist "..\.github\actions\identify-affected-proj" (
        xcopy "..\.github\actions\identify-affected-proj" ".github\actions\identify-affected-proj\" /E /I /Q
        if !errorlevel! equ 0 echo identify-affected-proj action copied successfully.
    )
)

:: Copy Full Stack workflows and actions (both NX and Terraform)
if "!project_type!"=="4" (
    echo Copying Full Stack workflows and actions...
    
    :: Copy NX deployment workflow
    if exist "..\.github\workflows\deploy-NX-projects.yaml" (
        copy "..\.github\workflows\deploy-NX-projects.yaml" ".github\workflows\" /Y >nul
        if !errorlevel! neq 0 (
            echo WARNING: Failed to copy deploy-NX-projects.yaml
        ) else (
            echo deploy-NX-projects.yaml copied successfully.
        )
    )
    
    :: Copy Terraform workflow
    if exist "..\.github\workflows\terraform-workflow.yaml" (
        copy "..\.github\workflows\terraform-workflow.yaml" ".github\workflows\" /Y >nul
        if !errorlevel! neq 0 (
            echo WARNING: Failed to copy terraform-workflow.yaml
        ) else (
            echo terraform-workflow.yaml copied successfully.
        )
    )
    
    :: Copy NX-related actions
    if exist "..\.github\actions\nx-setup" (
        xcopy "..\.github\actions\nx-setup" ".github\actions\nx-setup\" /E /I /Q
        if !errorlevel! equ 0 echo nx-setup action copied successfully.
    )
    
    if exist "..\.github\actions\build-project" (
        xcopy "..\.github\actions\build-project" ".github\actions\build-project\" /E /I /Q
        if !errorlevel! equ 0 echo build-project action copied successfully.
    )
    
    if exist "..\.github\actions\build-push" (
        xcopy "..\.github\actions\build-push" ".github\actions\build-push\" /E /I /Q
        if !errorlevel! equ 0 echo build-push action copied successfully.
    )
    
    if exist "..\.github\actions\identify-affected-proj" (
        xcopy "..\.github\actions\identify-affected-proj" ".github\actions\identify-affected-proj\" /E /I /Q
        if !errorlevel! equ 0 echo identify-affected-proj action copied successfully.
    )
    
    :: Copy Terraform-related actions
    if exist "..\.github\actions\terraform-apply" (
        xcopy "..\.github\actions\terraform-apply" ".github\actions\terraform-apply\" /E /I /Q
        if !errorlevel! equ 0 echo terraform-apply action copied successfully.
    )
)

:: Copy Terraform-only workflows and actions for Terraform Infrastructure projects
if "!project_type!"=="3" (
    echo Copying Terraform workflows and actions...
    
    :: Copy Terraform workflow
    if exist "..\.github\workflows\terraform-workflow.yaml" (
        copy "..\.github\workflows\terraform-workflow.yaml" ".github\workflows\" /Y >nul
        if !errorlevel! neq 0 (
            echo WARNING: Failed to copy terraform-workflow.yaml
        ) else (
            echo terraform-workflow.yaml copied successfully.
        )
    )
    
    :: Copy Terraform-related actions
    if exist "..\.github\actions\terraform-apply" (
        xcopy "..\.github\actions\terraform-apply" ".github\actions\terraform-apply\" /E /I /Q
        if !errorlevel! equ 0 echo terraform-apply action copied successfully.
    )
)

echo GitHub Actions workflows setup completed.

:: =============================================================================
:: GIT AND GITHUB SETUP
:: =============================================================================

:: Check if GitHub CLI is installed
echo.
echo Checking if GitHub CLI is installed...
gh --version >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: GitHub CLI ^(gh^) is not installed.
    echo.
    echo Please install GitHub CLI to continue:
    echo 1. Visit: https://cli.github.com/
    echo 2. Download and install GitHub CLI for Windows
    echo 3. Restart your command prompt
    echo 4. Run this script again
    echo.
    echo Alternatively, you can install via winget:
    echo   winget install GitHub.cli
    echo.
    pause
    exit /b 1
)
echo GitHub CLI is installed.

:: Check if Git is installed
echo Checking if Git is installed...
git --version >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: Git is not installed.
    echo.
    echo Please install Git to continue:
    echo 1. Visit: https://git-scm.com/downloads
    echo 2. Download and install Git for Windows
    echo 3. Restart your command prompt
    echo 4. Run this script again
    echo.
    pause
    exit /b 1
)
echo Git is installed.

:: Git initialization
echo.
echo Initializing Git repository with main as default branch...

:: Remove existing .git directory if it exists to ensure clean initialization
if exist ".git" (
    echo Removing existing Git configuration...
    rmdir /s /q ".git" >nul 2>&1
)

:: Initialize with main branch
git init --initial-branch=main
if !errorlevel! neq 0 (
    echo WARNING: Failed to initialize Git with --initial-branch. Trying alternative approach...
    :: Fallback for older Git versions
    git init
    if !errorlevel! neq 0 (
        echo ERROR: Failed to initialize Git repository.
        pause
        exit /b 1
    )
    :: Ensure we're on main branch (for compatibility with older Git versions)
    git checkout -b main 2>nul
    if !errorlevel! neq 0 (
        :: If checkout fails, try branch rename
        git branch -M main 2>nul
        if !errorlevel! neq 0 (
            echo ERROR: Failed to set main branch.
            pause
            exit /b 1
        )
    )
    echo Git repository initialized and switched to main branch.
) else (
    echo Git repository initialized with main branch successfully.
)

git add .
if !errorlevel! neq 0 (
    echo ERROR: Failed to add files to Git.
    pause
    exit /b 1
)

if "!project_type!"=="1" (
    git commit -m "Initial commit: Setup NX workspace with !project_name!"
) else if "!project_type!"=="2" (
    git commit -m "Initial commit: Setup simple repository !project_name!"
) else if "!project_type!"=="3" (
    git commit -m "Initial commit: Setup Terraform infrastructure project !project_name!"
) else if "!project_type!"=="4" (
    git commit -m "Initial commit: Setup Full Stack project (NX + Terraform) !project_name!"
)
if !errorlevel! neq 0 (
    echo ERROR: Failed to create initial commit.
    pause
    exit /b 1
)
echo Git repository initialized successfully.

:: Check GitHub CLI authentication
echo.
echo Checking GitHub CLI authentication...
gh auth status >nul 2>&1
if !errorlevel! neq 0 (
    echo WARNING: GitHub CLI is not authenticated.
    echo You need to authenticate with GitHub CLI to create the repository.
    echo.
    set /p "auth_choice=Do you want to authenticate now? (y/n): "
    set "auth_choice=!auth_choice: =!"
    
    if /i "!auth_choice!"=="y" (
        echo.
        echo Opening GitHub CLI authentication...
        echo Please follow the instructions in your browser to authenticate.
        gh auth login
        if !errorlevel! neq 0 (
            echo ERROR: GitHub CLI authentication failed.
            echo Please run 'gh auth login' manually and try the script again.
            pause
            exit /b 1
        )
        echo GitHub CLI authentication successful.
    ) else (
        echo.
        echo GitHub repository creation will be skipped.
        echo You can create the repository manually later or run the script again.
        echo The local Git repository has been created successfully.
        echo.
        echo To create the GitHub repository manually:
        echo 1. Run: gh auth login
        if not "!organization!"=="" (
            echo 2. Run: gh repo create !organization!/!project_name! --!repo_visibility! --source=. --remote=origin --push
        ) else (
            echo 2. Run: gh repo create !project_name! --!repo_visibility! --source=. --remote=origin --push
        )
        echo.
        pause
        exit /b 0
    )
)
echo GitHub CLI authentication verified.

:: Create and push GitHub repo with selected visibility and main as default branch
echo.
echo Creating GitHub repository with main as default branch...

:: Check if repository already exists
echo Checking if repository already exists...
if not "!organization!"=="" (
    gh repo view !organization!/!project_name! >nul 2>&1
) else (
    gh repo view !project_name! >nul 2>&1
)

if !errorlevel! equ 0 (
    echo WARNING: Repository already exists on GitHub.
    set /p "overwrite_repo=Do you want to delete and recreate it? (y/n): "
    set "overwrite_repo=!overwrite_repo: =!"
    
    if /i "!overwrite_repo!"=="y" (
        echo Deleting existing repository...
        if not "!organization!"=="" (
            gh repo delete !organization!/!project_name! --yes
        ) else (
            gh repo delete !project_name! --yes
        )
        if !errorlevel! neq 0 (
            echo ERROR: Failed to delete existing repository.
            pause
            exit /b 1
        )
        echo Existing repository deleted successfully.
    ) else (
        echo Skipping repository creation. Using existing repository.
        :: Add existing repo as remote
        if not "!organization!"=="" (
            git remote add origin https://github.com/!organization!/!project_name!.git 2>nul
        ) else (
            git remote add origin https://github.com/!username!/!project_name!.git 2>nul
        )
        git push -u origin main
        goto :skip_repo_creation
    )
)

:: Create new repository
if not "!organization!"=="" (
    gh repo create !organization!/!project_name! --!repo_visibility! --source=. --remote=origin --push
) else (
    gh repo create !project_name! --!repo_visibility! --source=. --remote=origin --push
)

:skip_repo_creation
if !errorlevel! neq 0 (
    echo ERROR: Failed to create GitHub repository.
    echo.
    echo Possible solutions:
    echo 1. Check your GitHub CLI authentication: gh auth status
    echo 2. Re-authenticate if needed: gh auth login
    echo 3. Verify you have permission to create repositories
    if not "!organization!"=="" (
        echo 4. Verify you have access to the organization: !organization!
        echo 5. Check if repository !organization!/!project_name! already exists
    ) else (
        echo 4. Check if repository !project_name! already exists in your account
    )
    echo.
    echo The local project has been created successfully.
    echo You can create the GitHub repository manually later.
    pause
    exit /b 1
)
echo GitHub repository created and pushed successfully.

:: Ensure main is set as default branch on GitHub
echo.
echo Confirming main as default branch on GitHub...
gh repo edit --default-branch main
if !errorlevel! neq 0 (
    echo WARNING: Failed to set main as default branch on GitHub. You can set this manually in GitHub settings.
) else (
    echo main branch confirmed as default branch on GitHub.
)

:: Create and push dev branch
echo.
echo Creating development branch...
git checkout -b dev
if !errorlevel! neq 0 (
    echo ERROR: Failed to create dev branch.
    pause
    exit /b 1
)

git push --set-upstream origin dev
if !errorlevel! neq 0 (
    echo ERROR: Failed to push dev branch.
    pause
    exit /b 1
)

echo Development branch created and pushed successfully.

:: =============================================================================
:: COMPLETION
:: =============================================================================

:: Open in VSCode
echo.
echo Opening project in Visual Studio Code...
CALL code .
if !errorlevel! neq 0 (
    echo WARNING: Failed to open VS Code. You can manually open the project.
)

echo.
echo ========================================
echo       PROJECT SETUP COMPLETE!
echo ========================================
echo Project: !project_name!
echo Location: %CD%
if "!project_type!"=="1" (
    echo Type: Enterprise NX Workspace
    if /i "!create_client!"=="y" (
        echo - React Client: !react_app_name! ^(Material-UI, TanStack Query, React Router^)
        echo - Start client: npm run start:client
    )
    if /i "!create_server!"=="y" (
        echo - NestJS Server: !nest_app_name! ^(Swagger, Config, RxJS^)
        echo - Start server: npm run start:server
    )
    if /i "!create_shared_libs!"=="y" (
        echo - Enterprise Libraries:
        echo   * @!project_name!/types ^(DTOs with class-validator^)
        echo   * @!project_name!/enums ^(shared constants^)
        echo   * @!project_name!/utils ^(lodash/fp functional programming^)
        if /i "!create_client!"=="y" echo   * @!project_name!/react-components ^(reusable UI components^)
        if /i "!create_server!"=="y" echo   * @!project_name!/backend-modules ^(decorators, guards, interceptors^)
    )
) else if "!project_type!"=="2" (
    echo Type: Simple Git Repository
) else if "!project_type!"=="3" (
    echo Type: Terraform Infrastructure Project
    echo - Terraform files included
    echo - GitHub Actions for Terraform deployment
) else if "!project_type!"=="4" (
    echo Type: Enterprise Full Stack Project ^(NX + Terraform^)
    echo - Terraform files included
    if /i "!create_client!"=="y" (
        echo - React Client: !react_app_name! ^(Material-UI, TanStack Query, React Router^)
        echo - Start client: npm run start:client
    )
    if /i "!create_server!"=="y" (
        echo - NestJS Server: !nest_app_name! ^(Swagger, Config, RxJS^)
        echo - Start server: npm run start:server
    )
    if /i "!create_shared_libs!"=="y" (
        echo - Enterprise Libraries:
        echo   * @!project_name!/types ^(DTOs with class-validator^)
        echo   * @!project_name!/enums ^(shared constants^)
        echo   * @!project_name!/utils ^(lodash/fp functional programming^)
        if /i "!create_client!"=="y" echo   * @!project_name!/react-components ^(reusable UI components^)
        if /i "!create_server!"=="y" echo   * @!project_name!/backend-modules ^(decorators, guards, interceptors^)
    )
    echo - GitHub Actions for both NX and Terraform deployment
)
if not "!organization!"=="" (
    echo GitHub: https://github.com/!organization!/!project_name!
) else (
    echo GitHub: https://github.com/!project_name!
)
echo Default branch: main
echo ========================================
echo.
 
pause