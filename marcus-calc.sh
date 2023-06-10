#!/bin/bash

#Script to figure out how much energy Marcus would have

#Usage: ./marcus.sh (Starting Condition) (Starting Energy)
#Valid Starting Conditions:
#Max:  Starts at a full 4800
#Rested:  Starts at a random number between 3600 and 4800 WH
#Tired:  Starts at a random number between 2400 and 4800 WH
#Exhausted:  Starts at a random number between 1200 and 2400 WH
#Depleted:  Starts at a random number between 0 and 1200 WH
#Custom:  Starts at a custom number


#Changelog
#01/14/21 - added some logic for crippled limbs.  Each limb has around 25% of his power capacity, so each limb that's crippled would be that much power lost proportionally.
#08/04/21 - added new ability, sound generation.  Also, fixed a bug where when no argument is given, the current charge errors out.
#05/06/23 - upgraded sound abilities.  Added tmux wrapper, splash screen, and colored percentage indicator.  Moved prompt to be less cluttered.
#05/11/23 - added Max power drain
#06/10/23 - changed units 

set -e

max=4800 #Default maximum power
crippled=0 #0 crippled limbs for default
cripfac=1 #Percentage of limbs which work, as a decimal.  Default is 1.
high=3600 #75% of Marcus' power at default
mid=2400 #50% at default
low=1200 #25% at default


# Colors
txt_red="\033[31m"    # Red
txt_green="\033[32m"  # Green
txt_yellow="\033[33m" # Yellow
txt_blue="\033[36m"   # Blue
txt_reset="\033[0m"   # Reset the prompt back to the default color



echo "---------------------------------------------------------" >> marcuslog
echo "[$(date)] Starting Marcus energy tracker" >> marcuslog
if [ -z $1 ]
then
sleep 0
else
echo "Starting argument is $1" >> marcuslog
fi
echo "Default max power is $max" >> marcuslog

if [ -z $2 ]
	then
		custom=$max
	else
		custom=$2
fi

if [ -z $1 ]
	then
		echo "What is Marcus' starting state?"
		echo "Max/Rested/Tired/Exhausted/Depleted/Custom/Crippled"
		read -p ">" start
		case $start in
			Custom|custom)
				echo "What is Marcus' custom charge?"
				read -p ">" custom
			;;
			Crippled|crippled)
				echo "How many limbs are crippled?"
				read -p ">" crippled
				echo "Marcus has $crippled crippled limbs, which won't provide power." >> macuslog
				cripfac=$(echo "scale=2;(4-$crippled)/4" | bc)
				max=$(echo "$max*$cripfac/1" | bc)
				high=$(echo "$high*$cripfac/1" | bc)
				mid=$(echo "$mid*$cripfac/1" | bc)
				low=$(echo "$low*cripfac/1" | bc)
				echo "Resetting Max power to $max" >> marcuslog
				echo "Setting 75% power to $high" >> marcuslog
				echo "Setting 50% power to $mid" >> marcuslog
				echo "Setting 25% power to $low" >> marcuslog
				echo "Asking for start again, with modified values for crippled limbs." >> marcuslog
				echo "What is Marcus' starting state?"
				echo "Max/Rested/Tired/Exhausted/Depleted/Custom"
				read -p ">" start
			;;
			*)
				sleep 0
			;;
		esac
	else
		start=$1
fi



case $start in
	Max|max)
		current=$max
		echo "Starting at Max" >> marcuslog
	;;
	Rested|rested)
		current=$(shuf -i $high-$max -n 1)
		echo "Starting rested." >> marcuslog
	;;
	Tired|Tired)
		current=$(shuf -i $mid-$high -n 1)
		echo "Starting tired." >> marcuslog
	;;
	Exhausted|exhausted)
		current=$(shuf -i $low-$mid -n 1)
		echo "Starting exhausted." >> marcuslog
	;;
	Depleted|depleted)
		current=$(shuf -i 0-$low -n 1)
		echo "Starting depleted." >> marcuslog
	;;
	Custom|custom)
		current=$custom
		echo "Starting at a custom level." >> marcuslog
	;;
	*)
	echo "Usage:  ./marcus.sh (State) (Custom WH)"
	echo "Valid states are:"
	echo "Rested Tired Exhausted Depleted Custom"
	echo "Custom WH only valid in custom state"
	echo "Invalid argument.  Exiting." >> marcuslog
	lsof -t marcuslog | xargs kill
	exit 1
	;;
esac

echo "Starting energy level $current WH" >> marcuslog

echo "Marcus is starting with $current WH of energy."

echo "Is Marcus using his holographic technology?"

read -p ">" hologram

case $hologram in
	Yes|yes|y)
		holo=20 #If yes, set usage to 20
		echo "Holographic tech on." >> marcuslog
	;;
	No|no|n)
		holo=0 #If no, set usge to 0
		echo "Holographic tech off." >> marcuslog
	;;
	*)
		echo "Assuming 'Yes'"
		echo "No argument; holographic tech set to 'on'" >> marcuslog
		holo=20
	;;
esac

echo $holo > holo

regen() ( #Logic for all the regeneration Marcus would do.  Usage:  regen (1 minute average usage) (duration)
holo=$(cat holo) # Pull current holography usage
	hourly_charge=$(shuf -i 15-30 -n 1) #Get an average charge rate
echo "Charging $hourly_charge WH" >> marcuslog
	drain=$1
	if [[ $(echo "$drain > $max" | bc) = 1 ]]
		then
    	echo "Usage above maximum limits.  $1 vs $max." >> marcuslog
    	echo "Setting power drain to max.  However, used ability might be unstable." >> marcuslog
    		drain=$max
    	else
    	sleep 0
    fi
echo "Power drain $drain WH" >> marcuslog
	charge_time=$(echo "scale=9;$hourly_charge/60" | bc) #How many minutes will it take to get 1 unit of energy at this average rate?
echo "Charging $charge_time WH/min" >> marcuslog
	use=$(echo "scale=9;$drain+$holo" | bc)
echo "Total usage including holography, $use Watts/min" >> marcuslog
	regen=$(echo "scale=9;$2*$charge_time"| bc) #How much power would he regenerate in the time specified? 
echo "Total regen $regen WH" >> marcuslog
	consumed=$(echo "scale=9;$use*$2" | bc) #How much power would he consume in the time specified?
echo "Total power consumed $consumed WH ">> marcuslog
	current=$(echo "scale=9;$current+$regen-$consumed" | bc) #Set the current amount of power to the old amount, plus the regen, minus the consumed power
	current=$(echo "scale=0;$current/1" | bc)
	echo "Current power $current WH" >> marcuslog
	if [[ $current -gt $max ]] #If the calculations put the power level above 4800, then...
		then
			echo "Fully charged.  $current is greater than $max.  Resetting to $max." >> marcuslog
			current=$max #Set the power level to maximum
		else
			sleep 0 #Bash doesn't really like nothing to be here, so I just put "sleep 0" to tell it to do nothing.
	fi
	if [[ $current -lt 0 ]] #If he's completely drained himself
		then
			current=1 #set it to 1.  Could do 0, but I'm worried that will break things.
			echo "Charge depleted.  Resetting to 1 WH" >> marcuslog
		else
			sleep 0
	fi
	echo $current #Bash requires you to echo these things back for some reason to apply it to a variable outside the function.
)


update_power() ( #Update how much power Marcus has.
	case $1 in
		Rest|rest) #Marcus is resting for x minutes.  Usage:  "Rest (time)
			echo "[$(date)] Marcus is resting for $2 minutes" >> marcuslog
			regen ".166666667" $2
		;;
		Move|move) #Marcus is being active for x minutes.  Usage:  "Move (time)
			echo "[$(date)] Marcus is being active for $2 minutes" >> marcuslog
			usagehr=$(shuf -i 10-40 -n 1) #Randomize an average usage total, between his lowest and highest activity numbers.
			echo "[$(date)] Usage calculated to $usage WH" >> marcuslog
			usage=$(echo "scale=9;$usagehr / 60" | bc)
			regen $usage $2
		;;
		Work|work|Exercise|exercise) #Marcus is exercising for x minutes, or is otherwise peaking out what he can physically use just by movement.  Usage:  Work/Exercise (duration)
			echo "[$(date)] Marcus is being very active for $2 minutes." >> marcuslog
			regen ".666666667" $2 #Set the usage to 40, which is his maximum.
		;;
		Telekinesis|telekinesis|Grab|grab) #Marcus is using his TK.  Usage:  Telekinesis (Duration) (Mass) (Distance)
			echo "[$(date)] Marcus is using his telekinesis on a $3 KG object at $4 Meters for $2 minutes" >> marcuslog
			usage=$(echo "scale=9;(( 10 * $4 ) + $3^2) / .70" | bc)
			regen $usage $2
		;;
		Light|light|Glow|glow) #Marcus is using his light manipulation.  Usage:  Light/Glow (Duration) (Mass) (Distance)
			echo "[$(date)] Marcus is using his light manipulation on $3 KG of mass at $4 meters for $2 minutes" >> marcuslog
			usage=$(echo "scale=9;(( 10 * $4 ) + $3^2 ) / .80" | bc)
			regen $usage $2
		;;
		Shock|shock) #Marcus is zapping something.  Usage:  Shock (Duration) (Mass) (Distance)
			echo "[$(date)] Marcus is shocking something using $3 KG of Mass at $4 Meters for $2 minutes on" >> marcuslog
			usage=$(echo "scale=9;(( 10 * $4 ) + $3^2 ) / .005" | bc)
			regen $usage $2
		;;
		Heat|heat|Warm|warm) #Marcus is using heat generation!  Usage:  Heat/Warm (Duration) (Mass) (Distance)
			echo "[$(date)] Marcus is warming $3 KG of Mass at $4 meters for $2 minutes" >> marcuslog
			usage=$(echo "scale=9;(( 10 * $4 ) + $3^2 ) / .10" | bc)
			regen $usage $2
		;;
		Sound|sound|Noise|noise) #Marcus is making sound!  Usage:  Sound/Noise (Duration) (Mass) (Distance)
			echo "[$(date)] Marcus is making sound, using $3 KG of Mass at $4 meters for $2 minutes" >> marcuslog
			usage=$(echo "scale=9;(( 10 * $4 ) + $3^2 ) / .40" | bc)
			regen $usage $2
		;;
		Recharge|recharge|Charge|charge) #Marcus is charging!  Usage:  Recharge/Charge (Duration) (Charge Rate/hr)
			echo "[$(date)] Marcus is charging for $2 minutes at $3 WH" >> marcuslog
			charge=$(echo "scale=9;$3 / 60" | bc) #How much does he recharge in 1 minute?
			echo "[$(date)] Cable Charge $charge Watts/min" >> marcuslog
			current=$(echo "scale=9;$current + ( $charge * $2 )" | bc) #Add how much he charges in x minutes to his current level, then
			echo "[$(date)]Calculated current charge without usage:  $current" >> marcuslog
			regen ".166666667" $2 #Add in his normal regen/usage
		;;
		Hologram|hologram|Holo|holo) #Holography!  Usage:  Hologram On/Off
			case $2 in
				On|on)
					echo 20 > holo
					echo "[$(date) Turning on hologram" >> marcuslog
				;;
				Off|off)
					echo 0 > holo
					echo "[$(date) Turning off hologram" >> marcuslog
				;;
			esac
			echo $current
		;;
		Quit|quit|Exit|exit) #Exiting the script
			echo "[$(date)] Exiting as ordered." >> marcuslog
			echo "[$(date)] Last charge for Marcus was $current." >> marcuslog
			lsof -t marcuslog | xargs kill
			exit 1
		;;
		Reset|reset)
			echo "Resetting power to $2" >> marcuslog
			echo $2
		;;
		*)
			echo "No argument given." >> marcuslog
			echo $current
		;;
esac
)

echo "What will Marcus do?"
echo "Rest/Move/Work (Duration)"
echo "Grab/Glow/Shock/Heat/Noise Command (Duration) (Mass) (Distance)"
echo "Holo On/Off"
echo "Recharge (Duration) (Rate)"

while true
	do
	percent=$(echo "scale=3;($current / $max) * 100" | bc)
	percent=$(echo "scale=0;($percent / 1)" | bc)
	if [[ $percent -gt 75 ]]
		then
		txt=$txt_blue
		elif [[ $percent -gt 50 ]]
		then
		txt=$txt_green
		elif [[ $percent -gt 25 ]]
		then
		txt=$txt_yellow
		else
		txt=$txt_red
	fi
echo -n -e "Marcus@$current($txt$percent%$txt_reset)>"
	read action
	if [[ "$action" = "Help" ]]
	then
	echo "What will Marcus do?"
	echo "Rest/Move/Work (Duration)"
	echo "Grab/Glow/Shock/Heat/Noise Command (Duration) (Mass) (Distance)"
	echo "Holo On/Off"
	echo "Recharge (Duration) (Rate)"
	else
	current=$(update_power $action)
	fi
done

