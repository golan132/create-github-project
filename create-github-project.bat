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
echo 1. NX Workspace (with NestJS/React setup)
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
if "!project_type!"=="3" (
    echo Terraform: Infrastructure files will be copied
    echo GitHub Actions: Terraform workflows will be included
) else if "!project_type!"=="4" (
    echo Terraform: Infrastructure files will be copied
    echo GitHub Actions: Both NX and Terraform workflows will be included
    if /i "!create_server!"=="y" echo Nest App Name: !nest_app_name!
    if /i "!create_client!"=="y" echo React App Name: !react_app_name!
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

:: Navigate to parent directory to create the new project
echo.
echo Navigating to parent directory...
cd ..
echo Current directory: %CD%

:: Create base workspace
echo.
echo Creating project structure...
if "!project_type!"=="1" (
    echo Setting up NX workspace...
    if /i "!create_server!"=="y" (
        echo Creating NX workspace with NestJS preset...
        CALL npx create-nx-workspace !project_name! --preset=nest --nxCloud=skip --packageManager=npm --appName=!nest_app_name! --e2eTestRunner=none --workspaceType=integrated --docker=false
    ) else (
        echo Creating basic NX workspace...
        CALL npx create-nx-workspace !project_name! --preset=apps --nxCloud=skip --packageManager=npm --workspaceType=integrated
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
        CALL npx create-nx-workspace !project_name! --preset=nest --nxCloud=skip --packageManager=npm --appName=!nest_app_name! --e2eTestRunner=none --workspaceType=integrated --docker=false
    ) else (
        echo Creating basic NX workspace...
        CALL npx create-nx-workspace !project_name! --preset=apps --nxCloud=skip --packageManager=npm --workspaceType=integrated
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
    if not exist "!project_name!" (
        echo ERROR: Failed to create project directory.
        pause
        exit /b 1
    )
    echo Directory created successfully.
)

cd "!project_name!"
echo Changed directory to: %CD%

:: React app setup (for NX workspace and Full Stack projects)
if "!project_type!"=="1" if /i "!create_client!"=="y" (
    echo.
    echo Setting up React application...
    CALL npm install -D @nrwl/react
    if !errorlevel! neq 0 (
        echo ERROR: Failed to install React dependencies.
        pause
        exit /b 1
    )
    
    CALL npx nx g @nrwl/react:app !react_app_name! --bundler=vite --e2eTestRunner=none --compiler=swc --pascalCaseFiles=true --unitTestRunner=none --routing=false --style=css --projectNameAndRootFormat=derived
    if !errorlevel! neq 0 (
        echo ERROR: Failed to generate React application.
        pause
        exit /b 1
    )
    echo React application created successfully.
) else if "!project_type!"=="4" if /i "!create_client!"=="y" (
    echo.
    echo Setting up React application for Full Stack project...
    CALL npm install -D @nrwl/react
    if !errorlevel! neq 0 (
        echo ERROR: Failed to install React dependencies.
        pause
        exit /b 1
    )
    
    CALL npx nx g @nrwl/react:app !react_app_name! --bundler=vite --e2eTestRunner=none --compiler=swc --pascalCaseFiles=true --unitTestRunner=none --routing=false --style=css --projectNameAndRootFormat=derived
    if !errorlevel! neq 0 (
        echo ERROR: Failed to generate React application.
        pause
        exit /b 1
    )
    echo React application created successfully.
)

:: Create shared types lib only if both server and client exist (for NX workspace and Full Stack projects)
if "!project_type!"=="1" if /i "!create_server!"=="y" if /i "!create_client!"=="y" (
    echo.
    echo Creating shared types library...
    CALL npx nx g @nrwl/js:lib types --bundler=swc --unitTestRunner=none --directory=libs --projectNameAndRootFormat=derived
    if !errorlevel! neq 0 (
        echo WARNING: Failed to create shared types library.
    ) else (
        echo Shared types library created successfully.
    )
) else if "!project_type!"=="4" if /i "!create_server!"=="y" if /i "!create_client!"=="y" (
    echo.
    echo Creating shared types library for Full Stack project...
    CALL npx nx g @nrwl/js:lib types --bundler=swc --unitTestRunner=none --directory=libs --projectNameAndRootFormat=derived
    if !errorlevel! neq 0 (
        echo WARNING: Failed to create shared types library.
    ) else (
        echo Shared types library created successfully.
    )
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

:: Always copy release-please.yml for all project types
if exist "..\.github\workflows\release-please.yml" (
    echo Copying release-please workflow...
    copy "..\.github\workflows\release-please.yml" ".github\workflows\" /Y >nul
    if !errorlevel! neq 0 (
        echo WARNING: Failed to copy release-please.yml
    ) else (
        echo release-please.yml copied successfully.
    )
) else (
    echo WARNING: release-please.yml not found at ..\.github\workflows\
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

:: Git initialization
echo.
echo Initializing Git repository...
git init --initial-branch=main
if !errorlevel! neq 0 (
    echo ERROR: Failed to initialize Git repository.
    pause
    exit /b 1
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

:: Create and push GitHub repo with selected visibility
echo.
echo Creating GitHub repository...
if not "!organization!"=="" (
    gh repo create !organization!/!project_name! --!repo_visibility! --source=. --remote=origin --push
) else (
    gh repo create !project_name! --!repo_visibility! --source=. --remote=origin --push
)
if !errorlevel! neq 0 (
    echo ERROR: Failed to create GitHub repository. Please check your GitHub CLI authentication.
    pause
    exit /b 1
)
echo GitHub repository created and pushed successfully.

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

:: Set main as default branch on GitHub (optional)
echo Setting main as default branch on GitHub...
gh repo edit --default-branch main
if !errorlevel! neq 0 (
    echo WARNING: Failed to set main as default branch on GitHub. You can set this manually in GitHub settings.
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
    echo Type: NX Workspace
    if /i "!create_client!"=="y" (
        echo - React Client: !react_app_name!
        echo - Start client: npm run start:client
    )
    if /i "!create_server!"=="y" (
        echo - NestJS Server: !nest_app_name!
        echo - Start server: npm run start:server
    )
) else if "!project_type!"=="2" (
    echo Type: Simple Git Repository
) else if "!project_type!"=="3" (
    echo Type: Terraform Infrastructure Project
    echo - Terraform files included
    echo - GitHub Actions for Terraform deployment
) else if "!project_type!"=="4" (
    echo Type: Full Stack Project ^(NX + Terraform^)
    echo - Terraform files included
    if /i "!create_client!"=="y" (
        echo - React Client: !react_app_name!
        echo - Start client: npm run start:client
    )
    if /i "!create_server!"=="y" (
        echo - NestJS Server: !nest_app_name!
        echo - Start server: npm run start:server
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