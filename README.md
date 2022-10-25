
# litter

Litter is a CAT1 re-issue tool to make the transition from CAT1 to CAT2 standard super easy! It uses Chias CAT1 Snaphshot, Chia CAT-admin-tool and a Chia Node+Wallet. All of these can be installed within the tool automatically. No need to do it seperately, though I recommend having the Chia Node/wallet already installed. Otherwise it will take the Chia Node days to get synced.

CAUTION: Though I tested this tool as good as I could, there is still a risk that something bad happens. I am not responsible for anything. This is the first version of the tool and it probably has some bugs and errors.


### Requirements

- Ubuntu 20.04
- OR
- Windows 10 / 11 with WSL (running Ubuntu 20.04). Chia has to be installed inside Ubuntu.
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

### Installing required tools

You can run the tool once without any configuration to install the required tools automatically. Note that it can also install the Chia-Blockchain Client which needs additional configuration steps.

```bash
bash litter.sh
```

litter will also ask you if you want to create a wallet key. Please note that it will create the new random key but you still have to transfer funds to the new wallet before you proceed.

Either copy the DB from your already running Node or you can download a near up-to-date DB at https://forksdata.com


### Additional WSL steps

If you are using WSL I recommend placing this DB in C:\temp\chia-db\blockchain_v2_mainnet.sqlite and to change the config.yaml accordingly. You will have to create the folder "temp" or use a different path. WSL has to have access to that folder though.

Open the config file with your favorite text editor:
```bash
nano ~/.chia/mainnet/config/config.yaml
```

Search for this line:
```bash
  database_path: db/blockchain_v2_CHALLENGE.sqlite
```
Change it in my example to this:
```bash
  database_path: /mnt/c/temp/chia-db/blockchain_v2_CHALLENGE.sqlite
```
Please make sure your DB is named correctly. "CHALLENGE" will be automatically replaced by the network name, in case of Chia "mainnet" automatically by Chia.


## Usage
Before you run the tool please make sure to add your OLD AssetIDs in the text file called assetids.txt. Just list them without any "" or spaces.

Open your the file with your favorite text editor, nano for example:
```bash
nano ~/litter/assetids.txt
```

Paste your AssetsIDS
```bash
6d3d2c9709d8e89d4707fa4f5f3e69269bd0b825a22da4fa45ed517da95136e0
14b40962dfef81d954ac0d92b51ec21ce7acd8c62dd9fef9303aa51c615cb495
```

Please make also sure you added your Wallet Fingerprint, Wallet ID and the Fee that should be used in the Config Section within litter.sh

```bash
#!/bin/bash
############################ Config Area ####
wallet_fingerprint="1234567890"
wallet_id="1"
fee="10000" #Fees in Mojo
############################ Config Area End ####
```

You can edit the file using your favorite text editor. Make sure you are not doing this on Windows itself. This could add some characters that would create a problem.

```bash
nano litter.sh
```
or
```bash
vi litter.sh
```
for example


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

My biggest thank you goes to out-grow! Thank you for all your help! You are a truly awesome person and I wouldnt be were I am without you!

You can visit one of his many many projects at https://littlelambocoin.com

He also provides the website https://forksdata.com on which we work together

You can make sure he can continue providing his services or just buy him a beer by donating:

CHIA Address xch1jvgusche3x62pmuazvy5fq4fnw5npheecsg5hafm6gdfxdryvm9qr404e6


A big thank you to https://github.com/WarutaShinken for helping me getting the CAT-admin-tool to run. Also for the fixes in my code.

If you want to help my buddy keep up his good work, consider buying him a beer:
CHIA Address xch1y46v09x3r77hv2560nw279lpxkg4dsq69d6sz5m9muuurwgrd6hqlpvm2y

## Donations

If you found this tool to help you, consider buying me a beer, or a beer factory, I am not your supervisor!
CHIA Address xch1ac74hll6w0ldmrpx3eldhxdck6e4hfyhdw5z8dt8seanfldyj0sqfna064
