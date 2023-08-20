@echo off
setlocal

:chooseFolder
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Choose a location for the new project.',0).self.path""

for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "folder=%%I"

setlocal enabledelayedexpansion
echo New project will be created in !folder!
endlocal
cd %folder%
:askProject
	set /p project_name= "New project name: " || goto :askProject
	rem check the folder name is valid
	rem https://stackoverflow.com/questions/45780452/how-to-verify-if-variable-contains-valid-filename-in-windows-batch
	setlocal enabledelayedexpansion
	for /f tokens^=2^ delims^=^<^>^:^"^/^\^|^?^*^ eol^= %%y in ("[!project_name!]") do (
        rem If we are here there is a second token, so, there is a special character
        echo Error : Non allowed characters in file name
        endlocal & goto :askProject
    )
	
	rem Check MAX_PATH (260) limitation
    set "my_temp_file=!folder!\!project_name!" & if not "!my_temp_file:~260!"=="" (
        echo Error : file name too long
        endlocal & goto :askProject
    )

    rem Check path inclusion, file name correction
    for /f delims^=^ eol^= %%a in ("!project_name!") do (
        rem Cancel delayed expansion to avoid ! removal during expansion
        endlocal

        rem Until checked, we don't have a valid file
        set "project_name="

        rem Check we don't have a path 
        if /i not "%%~a"=="%%~nxa" (
            echo Error : Paths are not allowed
            goto :askProject
        )

        rem Check it is not a folder 
        if exist "%%~nxa\" (
            echo Error : Folder with same name present 
            goto :askProject
        )

        rem ASCII 0-31 check. Check folder name can be created
        2>nul ( >>"%%~nxa" type nul ) || (
            echo Error : Folder name is not valid for this file system
            goto :askProject
        )

        rem Ensure it was not a special folder name by trying to delete the newly created folder
        2>nul ( del /q /f /a "%%~nxa" ) || (
            echo Error : Reserved file name used
            goto :askProject
        )

        rem Everything was OK - We have a folder name 
        set "project_name=%%~nxa"
    )
for %%I in (.) do set current_dir=%%~nxI
setlocal enabledelayedexpansion
if "%current_dir%"=="%project_name%" ( 
	echo Error: Already selected a folder with that name
	set /p double_dir= "Type X to choose another folder: "
	if /I "!double_dir!"=="X" endlocal & goto :chooseFolder
)
endlocal

:askTemplate
	setlocal enabledelayedexpansion
	rem get the template to use (default = basic_consult)
	set "template_name=basic_consult"
	set /p template_name= "Template to use (blank for default): "
	rem check that a folder with that name exists
	set "template_location=C:\Users\mdonoghoe\OneDrive - UNSW\General_consulting\_Template\new_project\project_templates"
	set "template_path=!template_location!\!template_name!"
	if not exist "!template_path!\" (
		echo Error : Template does not exist
		endlocal & goto :askTemplate
	)

rem get the current R version
setlocal enableextensions
set Rdir=
for /f "usebackq tokens=2*" %%A in (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\R-core\R" /v InstallPath`) DO (
	if not "%%~B"=="" set "Rdir=%%~B"
)
if not defined Rdir (
	echo "Error : Could not find installed R"
	exit /b 2
)
if not exist "%Rdir%" (
	echo Error : R path (%Rdir%^) does not exist
	exit /b 3
)

rem write the R script to create the project
set "template_location_R=!template_location:\=/!"
setlocal enabledelayedexpansion
(
	echo options(ProjectTemplate.templatedir = "%template_location_R%"^)
	echo ProjectTemplate::create.project(project.name = "%project_name%", template = "%template_name%"^)
) > create_project.R
endlocal

echo Creating project...
%Rdir%\bin\x64\Rscript create_project.R

echo Configuring project...
cd %project_name%
rem rename sample Rproj file
ren sample.Rproj "%project_name%.Rproj"
rem rename sample gitignore file
if exist .gitignore del /q .gitignore
ren sample_.gitignore .gitignore
rem delete template README
if exist README.md del /q README.md
rem edit the sample README file to include the project name
setlocal enabledelayedexpansion
echo !project_name! > README.md
(
	setlocal disabledelayedexpansion
	for /f "skip=1 delims=" %%L in ('findstr /n "^" sample_README.md') do (
		set "line=%%L"
		setlocal enabledelayedexpansion
		set "line=!line:*:=!"
		echo(!line!
		endlocal
	)
) >> README.md
if exist sample_README.md del /q sample_README.md
rem delete the cache folder & its contents
rmdir /s /q cache
rem make an empty cache folder & hide it
mkdir cache
attrib +h cache

echo Initialising git repo...
if exist .git del /s /q .git
if exist .git rmdir /s /q .git
git init
git config core.safecrlf false
git add .
git commit -q -m "Initial commit"

rem open the directory in file explorer
start .

cd ..
if exist create_project.R del /q create_project.R

echo Done!
pause