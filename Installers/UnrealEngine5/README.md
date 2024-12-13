Unreal Engine v.5.5.1
- Submit a request for a Developper account.
- Download the installer from the Developer Portal \
https://dev.epicgames.com/portal/en-US/university-for-the-creative-arts/service/unreal-engine/downloads 
 
FAB plugin (Essential for asset managment)
- Install Epic Games Launcher with the installer from this page \
https://store.epicgames.com/en-US/download  
- Login on the app and install the engine from there. 
- Install FAB plugin also from the Launcher.
 <img width="500" alt="Screenshot 2024-12-13 at 11 49 42" src="https://github.com/user-attachments/assets/37ce02f6-3716-48a7-8a31-10ed55dbdc5f" />

- Drop the folder below folder in composer \
/Users/Shared/Epic Games/UE_5.5.1/Engine/Plugins/Fab/ \
- Change the path to \
/Applications/UnrealEngine/Engine/Plugins/Fab/ \
- root:wheel Permissions from Epic Games Folder apply to all enclosed items. 
- Upload in Jamf to be deployed after the Engine.

UnrealEditor Alias 
- After the Dev package has been installed, create an Alias of the UnrealEditor app located here \
/Applications/UnrealEngine/Engine/Binaries/Mac/ in the applications folder. 
- Upload in jamf. 
 
Users will be able to manage the assets by login in Fab withing Unreal Engine with their own accounts. Click Drawers and click FAB tab. Top right, this launches the browser to authenticate. See screenshots. 
 
<img width="500" alt="Screenshot 2024-12-13 at 12 15 15" src="https://github.com/user-attachments/assets/66fbf720-77b6-4679-baf9-d73cdaa5de66" />
<img width="500" alt="Screenshot 2024-12-13 at 12 16 07" src="https://github.com/user-attachments/assets/f4cb53ff-00b5-4725-9160-5546140b1812" />
<img width="500" alt="Screenshot 2024-12-13 at 12 17 39" src="https://github.com/user-attachments/assets/85ea19e8-2227-47a0-aaf4-6bf1b52b0712" />
<img width="500" alt="Screenshot 2024-12-13 at 12 20 34" src="https://github.com/user-attachments/assets/e4e7a38b-8be7-4590-8d12-443cd3cf43ed" />

NOTE Unreal Engine requires Xcode to be able to run.
