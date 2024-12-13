Unreal Engine v.5.5.1
- Submit a request for a Developper account.
- Download the installer from the Developer Portal
https://dev.epicgames.com/portal/en-US/university-for-the-creative-arts/service/unreal-engine/downloads 
 
FAB plugin (Essential for asset managment) \
- Install Epic Games Launcher with the installer from this page \
https://store.epicgames.com/en-US/download  
- Login on the app and install the engine from there (5.5.0 and Above). 
- Install FAB plugin also from the Launcher.
 <img width="1860" alt="Screenshot 2024-12-13 at 11 49 42" src="https://github.com/user-attachments/assets/37ce02f6-3716-48a7-8a31-10ed55dbdc5f" />

Drop the folder 
/Users/Shared/Epic Games/UE_5.5.1/Engine/Plugins/Fab/  
in composer and change the path to   
/Applications/UnrealEngine/Engine/Plugins/Fab/ 
root:wheel Permissions from Epic Games Folder apply to all enclosed items. 
Upload in Jamf to be deployed after the Engine. 
UnrealEditor Alias 
After the Dev package has been installed, create an Alias of the UnrealEditor app  located /Applications/UnrealEngine/Engine/Binaries/Mac/ in the applications folder. 
Upload in jamf. 
 
Users will be able to manage the assets by login in Fab withing Unreal Engine with their own accounts. Click Drawers and click FAB tab. Top right, this launches the browser to authenticate. See screenshots. 
 
