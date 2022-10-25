#!/bin/bash
############################ Config Area ####
wallet_fingerprint="1234567890"
wallet_id="1"
fee="10000" #Fees in Mojo
############################ Config Area End ####
mojos_wallet_minimum="0"
token_endsum="0"
how_many_lines="0"
cd ~/litter
[ ! -d "temp" ] && mkdir -p "temp"
[ ! -d "logs" ] && mkdir -p "logs"
rm $HOME/litter/temp/token_sums.txt 2&>1 /dev/null
touch $HOME/litter/temp/token_sums.txt

# COLOR SECTION
    ### Colors ##
    ESC=$(printf '\033') RESET="${ESC}[0m" BLACK="${ESC}[30m" RED="${ESC}[31m"
    GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" MAGENTA="${ESC}[35m"
    CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m"
   
    ### Color Functions ##

    greenprint() { printf "${GREEN}%s${RESET}\n" "$1"; }
    blueprint() { printf "${BLUE}%s${RESET}\n" "$1"; }
    redprint() { printf "${RED}%s${RESET}\n" "$1"; }
    yellowprint() { printf "${YELLOW}%s${RESET}\n" "$1"; }
    magentaprint() { printf "${MAGENTA}%s${RESET}\n" "$1"; }
    cyanprint() { printf "${CYAN}%s${RESET}\n" "$1"; }
    fn_goodafternoon() { echo; echo "Good afternoon."; }
    fn_goodmorning() { echo; echo "Good morning."; }
    fn_bye() { echo "Bye bye."; exit 0; }
    fn_fail() { echo "Wrong option." exit 1; }


#Automatic installed packages check
  cd ~
  echo -e "Installing/Updating dependencies\n"
  echo -e "Your sudo password might be needed:\n\n"
  sudo apt install unzip git python3 build-essential python3-dev python3-venv -y #FIX
function chia_activate {
  cd $HOME/chia-blockchain
  . ./activate
  cd -
}
function cat_admin_activate {
  cd $HOME/litter/CAT-admin-tool
  . ./venv/bin/activate
  cd -
}
function check_chia_sync {


  #Chia Blockchain synced status

  until [ `chia rpc full_node get_blockchain_state | grep synced | cut -d ":" -f 2 | cut -d " " -f 2` == "true" ] #FIX
    do
            echo  -e "${YELLOW}Chia Full_Node not synced!${DEFAULT}"
            sleep 30s
  done

  #Wallet status checks

  while true; do
  check_wallet_running=$(chia wallet show -f "$wallet_fingerprint" | grep "Connection error" | cut -d "." -f 1 | cut -d " " -f 2 )
    if [ "$check_wallet_running" == "error" ]
    then
        echo -e "\nWallet not running!\n\nTrying to start/restart Chia Node and Wallet\n\n"
        chia start node
        chia start wallet
        sleep 20
        continue
    else
      echo -e "Wallet up and running" #FIX
      break
    fi
  done
  until [ `chia rpc wallet get_sync_status  | grep "synced"   | cut -d"\"" -f 3  | cut -d" " -f2  | cut -d"," -f1` == "true" ] #FIX
  do
          chia wallet show -f $wallet_fingerprint
          echo  -e "${YELLOW}SEND Wallet not synced!${DEFAULT}"
          sleep 30s
  done
  until [ `chia rpc wallet get_wallet_balance '{"wallet_id": '$wallet_id'}' | grep "spendable_balance" | cut -d ":" -f 2 | cut -d " " -f2 | cut -d "," -f1` -ge "$mojos_wallet_minimum" ] #FIX
  do
          echo  -e "${YELLOW}SEND Wallet not ready...not enough spendable balance${DEFAULT}"
          sleep 10s
  done
}
function main_logic {
  while IFS= read -r line; do
    asset_id=$(echo $line | cut -d "," -f 1 )
    total_amount=$(echo $line | cut -d "," -f 2 )
    #rm $HOME/litter/logs/old_asset_id_$asset_id.log
    filename=$(ls -1 $HOME/litter/chia-cat1-snapshot/cat1_csv_files/ | grep $asset_id)
    echo $filename >> $HOME/litter/logs/old_asset_id_$asset_id.log
    selected_coin=$(cats --tail $HOME/litter/CAT-admin-tool/reference_tails/genesis_by_coin_id.clsp.hex -f $wallet_fingerprint --send-to xch1ac74hll6w0ldmrpx3eldhxdck6e4hfyhdw5z8dt8seanfldyj0sqfna064 --amount $total_amount --as-bytes --select-coin | grep "Name:" | cut -d ":" -f 2 | cut -d " " -f 2)
    echo "Selected Coin: \"$selected_coin\"" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    selected_coin_hex=$(echo "0x$selected_coin")
    echo "Selected Coin in HEX: \"$selected_coin_hex\"" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    root_puzzle_hash_and_address=$(secure_the_bag --tail $HOME/litter/CAT-admin-tool/reference_tails/genesis_by_coin_id.clsp.hex --amount $total_amount --secure-the-bag-targets-path $HOME/litter/chia-cat1-snapshot/cat1_csv_files/$filename --prefix xch --curry $selected_coin_hex)
    echo "Root puzzle hash and address: \"$root_puzzle_hash_and_address\"" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    root_puzzle_hash=$(echo "$root_puzzle_hash_and_address" | grep "hash:" | cut -d ":" -f 2 | cut -d " " -f 2 )
    root_address=$(echo "$root_puzzle_hash_and_address" | grep "address:" | cut -d ":" -f 2 | cut -d " " -f 2 )
    echo "Root puzzle hash: \"$root_puzzle_hash\"" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    echo "Root puzzle address: \"$root_address\"" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    push_to_network=$(yes | cats --tail $HOME/litter/CAT-admin-tool/reference_tails/genesis_by_coin_id.clsp.hex -f $wallet_fingerprint --send-to $root_address --amount $total_amount --as-bytes --curry $selected_coin_hex --fee $fee)
    echo "$push_to_network" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    new_asset_id=$(echo "$push_to_network" | grep "Asset ID:" | cut -d ":" -f 2 | cut -d " " -f 2 )
    echo "CAT2 s new Asset ID: \"$new_asset_id\"" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    eve_coin_id=$(echo "$push_to_network" | grep "Coin ID:" | cut -d ":" -f 2 | cut -d " " -f 2 )
    echo "Eve Coin ID: \"$eve_coin_id\"" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    echo "This File will be used: $HOME/litter/chia-cat1-snapshot/cat1_csv_files/$filename"
    unwind_the_bag=$(unwind_the_bag --eve-coin-id $eve_coin_id --tail-hash $new_asset_id --secure-the-bag-targets-path $HOME/litter/chia-cat1-snapshot/cat1_csv_files/$filename -f $wallet_fingerprint --unwind-fee $fee --wallet-id 1)
    echo "$unwind_the_bag" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    temp_token_issued="0"
    ((temp_token_issued=total_amount/1000))
    echo -e "\t######### SUMMARY ##########" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    echo -e "\tOld CAT1 Token AssetID:\t $asset_id" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    echo -e "\t---------------------------------" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    echo -e "\tNew AssetID: $new_asset_id" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    echo -e "\tTotal Amount of Mojos to be minted:\t $total_amount" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    echo -e "\tTokens to be minted:\t\t (($temp_token_issued))" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    echo -e "\t######### END SUMMARY ##########\n\n\n" >> $HOME/litter/logs/old_asset_id_$asset_id.log
    cat $HOME/litter/logs/old_asset_id_$asset_id.log
  done < $HOME/litter/temp/token_sums.txt
}
#Chia Snapshot detection and install
  DIR="$HOME/litter/chia-cat1-snapshot"
  if [ -d "$DIR" ]; then
    echo "${DIR} detected..."
  else
      while true; do
        echo -e "Error: No ${DIR} exists.\n\n Do you want to download Chia CAT1 Snapshot?\n "
        read -p "([yY]/[nN]) " ynsnap
        case $ynsnap in 
          [yY] ) echo "downloading Snapshot...";
            cd $HOME/litter
            mkdir chia-cat1-snapshot
            cd chia-cat1-snapshot
            wget -v https://cat1-download.chia.net/file/cat1-download/cat1-snapshot.zip
            unzip cat1-snapshot.zip
            cd ~
            echo "Downloaded Chia CAT1 Snapshot successfully!"
            break;;
          [nN] ) echo "Cannot continue without snapshot, please download manually";
            exit;;
          * ) echo "invalid response; exiting"; 
            exit;;
        esac
      done
  fi


#Chia Blockchain Client detection and install
  DIR="$HOME/chia-blockchain"
  if [ -d "$DIR" ]; then
    echo "${DIR} detected..."
  else
      while true; do
          echo -e "\n\nError: No ${DIR} exists.\n\n Do you want to install Chia Blockchain Client Version 1.6.0?\n "
          read -p "([yY]/[nN]) " ynchia
          case $ynchia in
            [yY] ) echo -e "Installing Chia 1.6.0...\n";
              cd ~
              git clone https://github.com/Chia-Network/chia-blockchain -b 1.5.0 && cd chia-blockchain && sh install.sh && . ./activate && chia init && chia init --fix-ssl-permissions
                while true; do
                  echo -e "Do you want Chia to create a new random key?\n\n";
                  read -p "([yY]/[nN]) " ynkey
                  case $ynkey in
                  [yY] ) echo -e "Creating new key...\n";
                    cd $HOME/chia-blockchain
                    . ./activate
                    chia keys generate
                    chia keys show --show-mnemonic-seed
                    deactivate
                    cd ~
                      while true; do
                        echo -e "\n\nDo you want the Chia GUI to be installed?\n"
                        read -p "([yY]/[nN]) " yngui
                        case $yngui in
                        [yY] ) echo -e "\nInstalling Chia GUI\n"
                          cd $HOME/chia-blockchain
                          . ./activate
                          bash install-gui.sh
                          deactivate
                          echo -e "\n\n GUI successfully installed!\n"
                          cd ~
                          break;;
                        [nN] ) echo -e "Chia GUI will not be installed!"
                          break;;
                        * ) echo "invalid response; exiting"; 
                          exit;;
                        esac
                      done
                    break;;
                  [nN] ) echo -e "Continue without key...Please make sure a key is added in config\n";
                    break;;
                  * ) echo "invalid response; exiting"; 
                    exit;;
                  esac
                done
              cd ~
              break;;
            [nN] ) echo "Cannot continue without Chia Blockchain Client, please download and install manually";
              exit;;
            * ) echo "invalid response; exiting"; 
              exit;;
          esac
      done
  fi


#CAT Admin Tool detection and install
  # DIR="$HOME/litter/CAT-admin-tool"
  # if [ -d "$DIR" ]; then
  #   echo "${DIR} detected..."
  # else
  #     while true; do
  #       echo -e "Error: No ${DIR} folder detected in Home dir.\n\nDo you want to install CAT-admin-tool?\n"
  #       read -p "([yY]/[nN]) " yncat
  #       case $yncat in 
  #         [yY] ) echo "downloading Snapshot...";
  #           cd ~/litter
  #           git clone https://github.com/morph3us1984/CAT-admin-tool.git -b main
  #           cd ~/litter/CAT-admin-tool
  #           python3 -m venv venv #FIX
  #           . ./venv/bin/activate
  #           python3 -m pip install --upgrade pip setuptools wheel click #FIX
  #           pip install .
  #           pip install chia-dev-tools --no-deps
  #           pip install pytest
  #           pip install chia-blockchain==1.5.0
  #           pip install pytest-asyncio
  #           pip install pytimeparse
  #           cats --help
  #           cdv --help
  #           echo -e "\nInstalled CAT-admin-tool successfully!\n\n"
  #           break;;
  #         [nN] ) echo "Cannot continue without Cat-admin-tool, please download manualy";
  #           exit;;
  #         * ) echo "invalid response; exiting"; 
  #           exit;;
  #       esac
  #     done
  # fi
#testing a different version of CAT-admin-tool
DIR="$HOME/litter/CAT-admin-tool"
  if [ -d "$DIR" ]; then
    echo "${DIR} detected..."
  else
      while true; do
        echo -e "Error: No ${DIR} folder detected in Home dir.\n\nDo you want to install CAT-admin-tool?\n"
        read -p "([yY]/[nN]) " yncat
        case $yncat in 
          [yY] ) echo "downloading Snapshot...";
            cd ~/litter
            git clone https://github.com/morph3us1984/CAT-admin-tool
            cd ~/litter/CAT-admin-tool
            python3 -m venv venv #FIX
            . ./venv/bin/activate
            python3 -m pip install --upgrade pip setuptools wheel click #FIX
            pip install .
            pip install chia-dev-tools --no-deps
            pip install pytest
            pip install chia-blockchain==1.5.0
            pip install pytest-asyncio
            pip install pytimeparse
            cats --help
            cdv --help
            echo -e "\nInstalled CAT-admin-tool successfully!\n\n"
            break;;
          [nN] ) echo "Cannot continue without Cat-admin-tool, please download manualy";
            exit;;
          * ) echo "invalid response; exiting"; 
            exit;;
        esac
      done
  fi
#Fingerprint check
    if [ "$wallet_fingerprint" == "" ] ; then
        echo "Wallet Fingerprint is not set!"
        exit
    fi
    if [ "$wallet_fingerprint" == "1234567890" ] ; then
        echo "You forgot to set your Wallet Fingerprint!"
        exit
    fi
#Old AssetIDs check and Calculations
  assetidfile="$HOME/litter/assetids.txt"
  if [[ -s $assetidfile ]] ; then
    while IFS= read -r line; do
        filename=$(ls -1 $HOME/litter/chia-cat1-snapshot/cat1_csv_files/ | grep $line)
        if [ -z "$filename" ]
        then
          echo "AssetID: $line not found in the Chia Snapshot. Exiting Tool. Please create your own custom Snapshot for this AssetID!"
          exit
        else
        #whatever is next
        echo "AssetID: $line was found. Filename is $filename"
        fi
    done < $assetidfile
  else
    echo "assetids.txt is empty. Please populate file with your old Asset IDs!" #FIX
    exit
  fi

  #Getting Endsum for each AssetIDs
  
  while IFS= read -r line; do
    filename=$(ls -1 $HOME/litter/chia-cat1-snapshot/cat1_csv_files/ | grep $line)
    line_amount=$(cat $HOME/litter/chia-cat1-snapshot/cat1_csv_files/$filename | wc -l)
    ((how_many_lines=how_many_lines+line_amount))
    #echo "$filename"
    tokens_sum=0
    while IFS= read -r linecountingtokens; do
      #echo "$linecountingtokens"
      tokens_temp_count=$(echo "$linecountingtokens" | cut -d "," -f 2 )
      #echo $tokens_sum
      #echo $tokens_temp_count
      #tokens_sum=$(expr $tokens_sum + $tokens_temp_count)
      tokens_temp_count_correct="$((${tokens_temp_count//[ $'\001'-$'\037']}))"
      #echo $tokens_temp_count_correct
      ((tokens_sum=tokens_sum+tokens_temp_count_correct))
    done < $HOME/litter/chia-cat1-snapshot/cat1_csv_files/$filename
    echo -e "$line,$tokens_sum" >> $HOME/litter/temp/token_sums.txt
  done < $assetidfile
  
  cat $HOME/litter/temp/token_sums.txt
  
  while IFS= read -r token_endsum_temp; do
      token_endsum_temp=$(echo "$token_endsum_temp" | cut -d "," -f 2 )
      token_endsum_temp_correct="$((${token_endsum_temp//[ $'\001'-$'\037']}))"
      #echo $tokens_temp_count_correct
      ((token_endsum=token_endsum+token_endsum_temp_correct))
      ((mojos_wallet_minimum=token_endsum*1000))
  done < $HOME/litter/temp/token_sums.txt
  echo -e "\n\nThe sum of all Tokens in Mojo is: $token_endsum\n\n"
  echo -e "There are $how_many_lines unique addresses to send tokens to\n"
  ((fee_sum=how_many_lines*fee))
  echo -e "Minting CAT2 Tokens will cost $fee_sum mojos in Fees\n"
  ((mojos_wallet_minimum=fee_sum+token_endsum))
  echo -e "you will need $mojos_wallet_minimum mojos to mint all CAT2 Tokens\n"
#Ask to start Main Logic
  while true; do
  echo -e "\n\nAll AssetIDs are valid. Do you want to continue issueing the new CAT2 Standard Tokens?"
  read -p "([yY]/[nN]) " ynstart
  case $ynstart in 
          [yY] ) echo -e "\nStarting issuing CATs...\n\n";
            chia_activate
            check_chia_sync
            cat_admin_activate
            main_logic
            echo -e "\nBeepBoopBeep\n\n"
            break;;
          [nN] ) echo -e  "\nAlright, exiting tool...\n\n";
            exit;;
          * ) echo "invalid response; exiting"; 
            exit;;
        esac
  done
