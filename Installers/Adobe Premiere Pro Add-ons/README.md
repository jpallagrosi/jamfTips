Adobe does not offer the option to package them separately.

Create a Premiere Pro package in the Adobe portal, add the Language Speech to text needed and install on a test machine.
The Add-on from the Adobe package will be located here:
/Library/Application Support/Adobe/Premiere Pro/SpeechESL/2.1.6_b31d91e1d8_esl/ Create a package as shown in the screenshot below.

<img width="1221" alt="Screenshot 1 - Packaged" src="https://github.com/user-attachments/assets/e07264fd-ee51-458e-b211-26caabc63685">

AdobePremierProAddon.sh will check whether there is another pack installed or not. If so it will use the same directory if not it will use the PLACEHOLDER folder to create it. Add the last 2 digits of the Premiere Pro Year in parameter 4 of the policy.
Below how it should look like after deployment:

<img width="912" alt="Screenshot 2 - Deployed" src="https://github.com/user-attachments/assets/6ab9fd5d-acdc-48c1-8156-cc7704de4ab9">
