
# litter

Litter is a CAT1 re-issue tool to make the transition from CAT1 to CAT2 standard super easy! It uses Chias CAT1 Snaphshot, Chia CAT-admin-tool and a Chia Node+Wallet. All of these can be installed within the tool automatically. No need to do it seperately, though I recommend having the Chia Node/wallet already installed. Otherwise it will take the Chia Node days to get synced.

CAUTIONn: Though I tested this tool as good as I could, there is still a risk that something bad happens. I am not responsible for anything. This is the first version of the tool and it probably has some bugs and errors.


## Requirements

- Ubuntu 20.04
- OR
- Windows 10 / 11 with WSL (running Ubuntu 20.04)
- Synced Chia Full Node
- Synced Chia Wallet


## Installation

litter has to be installed in the home directory of the User. 

Install litter using:

```bash
  cd ~
  git clone https://github.com/morph3us1984/litter
  cd litter
```

Before you run the tool please make sure to add your OLD AssetIDs in the text file called assetids.txt. Just list them without any "" or spaces.

```
6d3d2c9709d8e89d4707fa4f5f3e69269bd0b825a22da4fa45ed517da95136e0
14b40962dfef81d954ac0d92b51ec21ce7acd8c62dd9fef9303aa51c615cb495
```

Please make also sure you added your Wallet Fingerprint, Wallet ID and the Fee that should be used in the Config Section within litter.sh

```
#!/bin/bash
############################ Config Area ####
wallet_fingerprint="1234567890"
wallet_id="1"
fee="10000" #Fees in Mojo
############################ Config Area End ####
```

You can edit the file using your favorite text editor. Make sure you are not doing this on Windows itself. This could add some characters that would create a problem.

```
nano litter.sh
or
vi litter.sh
```

After everything is set, you can start the tool with the command:

```
bash litter.sh
```

You will be asked at every step to proceed or not. Just answer with Y/y or N/n. Every other input signals the tool to exit.
## Logs

Every time the tool is run, a log file will be created in the folder "logs" within the litter folder.
The filepath should look like this: "litter/logs/old_asset_id_<your_old_AssetID>.log"

Here you can find all the information that you need for the new Tokens if you missed it in the CLI Output. Aswell as the new AssetID of the CAT2. Make sure to make a backup of this file.

## Thank you

A big thank you to https://github.com/WarutaShinken for helping me getting the CAT-admin-tool to run. Also for the fixes in my code.

If you want to help my buddy keep up his good work, consider buying him a beer:
CHIA Address xch1y46v09x3r77hv2560nw279lpxkg4dsq69d6sz5m9muuurwgrd6hqlpvm2y

##

If you found this tool to help you, consider buying me a beer, or a beer factory, I am not your supervisor!
CHIA Address xch1ac74hll6w0ldmrpx3eldhxdck6e4hfyhdw5z8dt8seanfldyj0sqfna064
