#!/usr/bin/bash
while true
do
echo -e "	\n	Welcome to Food Express \n	=======================\n"
echo -e "	1. Available Restaurants \n"
echo -e "	2. Nearby Restaurants \n"
echo -e "	3. Orders \n"
echo -e "	4. Manage \n"
echo -e "	0. Exit \n"
echo  -n "	Enter your choice: "

read choice



if [[ $choice == "1" ]]
then
	while true
	do
	clear
	echo -e "\n	Available Restaurants In Districts \n	--------------- \n"
	filedir="$PWD/restaurants"
	if [ ! -d $filedir ]
	then
		echo "	No data available"
	else
		filepath="$filedir/res_num_dis"
		file_count=`wc --lines < $filepath`
		if [ "$file_count" == 0 ]
		then
			echo "	No Data Available"
		
		else
			cat --number-nonblank  "$filepath"
		fi
	fi
	
	
	echo -e "\n \n	0. Main Menu \n"
	echo  -n "	Enter Restaurant No. (Details/Order Food): "
	read choicea
	RES=`awk "NR==$choicea" $PWD/restaurants/restaurants`
	if [[ $choicea == "0" ]]
	then
		clear
		echo -e "\n	Main Menu \n"
		break
	fi
	if [[ -z "$RES" ]]
	then
		clear
		echo -e "\n	ERROR: Not in options  \n"
		continue
	
	else
		clear
		echo " "
		resfile="$PWD/restaurants/$RES.txt"
		cat $resfile
		
		echo -e "\n \n	Order from this restaurant"
		echo -e "	0. Go Back"
		echo -n "	Enter Food Item no. :"
		read or_cp
		total_line=`wc --lines < $PWD/restaurants/$RES.txt`
		higher=6
		total_lines=`expr "$total_line" - "$higher"`
		total_items=`expr "$total_lines" / 2`
		if [[ $or_cp == "0" ]]
		then
			clear
			echo -e " "
			continue
		fi
		lower=0
		re='^[0-9]+$'
		if [[ "$total_items" -lt "$or_cp" ]]
		then
			clear
			sleep 1
			echo -e "\n	Item not available! \n"
			sleep 1
			continue
		elif ! [[ $or_cp =~ $re ]] 
		then
			clear
			sleep 1
			echo -e "\n	Wrong Entry! \n"
			sleep 1
			continue
		
		fi
		lines=`expr "$or_cp" + 1`
		line=`expr "$lines"\*2`
		item=`awk "NR==$line" $PWD/restaurants/$RES.txt`
		echo ""
		echo -e "\n	Selected Item: $item"
		
		while true
		do
		echo -n "	Enter Quantity: "
		read qty
		re='^[0-9]+$'
		if ! [[ $qty =~ $re ]] 
		then
			echo -e "	Error! Qantity must be a number"
			continue
		else
			break
		fi
		done
		
		NET=`curl -Is  http://www.google.com | head -n 1`
		if [[ -z "$NET" ]]
		then
			echo -e "\n	Not Connected to the internet! Auto Location Service\n"
			echo -n "	Enter Your District: "
			read location
			echo -e "\n	Your Location: $location"
		else
			PUBLIC_IP=`curl -s https://ipinfo.io/ip`
			location=`curl -s https://ipinfo.io/${PUBLIC_IP}/city`
			echo -e "\n	Your Location: $location"
		fi

		echo -n "	Enter Your Exact Address: "
		read exact
		echo -n "	Enter Your Contact Info (Mobile no.): "
		read phone
		echo ""
		echo -n "	Are you sure to order? ("y" to confirm): "
		read confirm
		if [[ "$confirm" == "y" ]]
		then
			
			dir_order="$PWD/restaurants/orders"
			if [ ! -d $dir_order ] 
			then
				mkdir $dir_order
			fi
			c1=`date +%d`
			c2=`date +%H`
			c3=`date +%M`
			today=`date`
			code="${c1}${c2}${c3}"
			item_price=`awk "NR==$or_cp" $PWD/restaurants/$RES.item`
			total_bill=`expr "$item_price" \* "$qty"`
			clear
			echo -e "\n	--> Please Wait <----- \n"
			sleep 1
			echo "	Code: $code | $RES : Total Bill - $total_bill | $location - $exact">> "$dir_order/orders"
			echo "$code">>"$dir_order/codes"
			echo " ">>"$dir_order/$code.txt"
			echo "	Order Details: $RES">>"$dir_order/$code.txt"
			echo "	------------------------">>"$dir_order/$code.txt"
			echo " ">>"$dir_order/$code.txt"
			echo "	Item Ordered: $item">>"$dir_order/$code.txt"
			echo "	Quantity Ordered: $qty">>"$dir_order/$code.txt"
			echo "	Total = $total_bill">>"$dir_order/$code.txt"
			echo "	------------------------">>"$dir_order/$code.txt"
			echo "	Order Location: $location, $exact">>"$dir_order/$code.txt"
			echo "	Order phone no: $phone">>"$dir_order/$code.txt"
			echo "	Order Date: $today">>"$dir_order/$code.txt"
			clear
			
			sleep 1
			echo -e "\n	Order Confirmed! \n"
		else
			clear
			echo -e "\n	--> Cancelling Order ! <----- \n"
			sleep 1
			clear
		fi
		break
	fi
	done
	
elif [[ $choice == "2" ]]
then
	while true
	do
	clear
	NET=`curl -Is  http://www.google.com | head -n 1`
	if [[ -z "$NET" ]]
	then
		clear
		echo -e "\n	Not Connected! Check your network and try again! \n"
		sleep 1
		break
	else
		echo -e "	Connected to the internet"
	fi
	
	PUBLIC_IP=`curl -s https://ipinfo.io/ip`
	location=`curl -s https://ipinfo.io/${PUBLIC_IP}/city`
	echo -e "\n	Your Ip: $PUBLIC_IP"
	echo -e "\n	Your Current Location: $location\n	------------------------"
	echo -e "	Restaurants Nearby You \n	------------------------ \n"
	filedir="$PWD/restaurants/"
	if [ ! -d $filedir ]
	then
		echo "	No data available"
	else
		near_path="$PWD/restaurants/$location.lst"
		file_count=`wc --lines < $near_path`
		if [ "$file_count" == 0 ]
		then
			echo "	No Data Available"
		
		else
			cat --number-nonblank "$near_path"
		fi
	fi
	
	
	echo -e "\n \n	0. Main Menu \n"
	echo  -n "	Enter Restaurant No. (Details/Order Food): "
	read choicea
	RES=`awk "NR==$choicea" $PWD/restaurants/$location.item`
	if [[ $choicea == "0" ]]
	then
		clear
		echo -e "\n	Main Menu \n"
		break
	fi
	if [[ -z "$RES" ]]
	then
		clear
		sleep 1
		echo -e "\n	ERROR: Not in options  \n"
		sleep 1
		continue
	
	else
		clear
		echo " "
		resfile="$PWD/restaurants/$RES.txt"
		cat $resfile
		
		echo -e "\n \n	Order from this restaurant"
		echo -e "	0. Go Back"
		echo -n "	Enter Food Item no. :"
		read or_cp
		total_line=`wc --lines < $PWD/restaurants/$RES.txt`
		higher=6
		total_lines=`expr "$total_line" - "$higher"`
		total_items=`expr "$total_lines" / 2`
		if [[ $or_cp == "0" ]]
		then
			clear
			echo -e " "
			continue
		fi
		lower=0
		re='^[0-9]+$'
		if [[ "$total_items" -lt "$or_cp" ]]
		then
			clear
			sleep 1
			echo -e "\n	Item not available! \n"
			sleep 1
			continue
		elif ! [[ $or_cp =~ $re ]] 
		then
			clear
			sleep 1
			echo -e "\n	Wrong Entry! \n"
			sleep 1
			continue
		
		fi
		lines=`expr "$or_cp" + 1`
		line=`expr "$lines"\*2`
		item=`awk "NR==$line" $PWD/restaurants/$RES.txt`
		echo ""
		echo -e "\n	Selected Item: $item"
		
		while true
		do
		echo -n "	Enter Quantity: "
		read qty
		if ! [[ $qty =~ $re ]] 
		then
			echo -e "	Error! Qantity must be a number"
			continue
		else
			break
		fi
		done
		
		NET=`curl -Is  http://www.google.com | head -n 1`
		if [[ -z "$NET" ]]
		then
			echo -e "\n	Not Connected to the internet! Auto Location Service\n"
			echo -n "	Enter Your District: "
			read location
			echo -e "\n	Your Location: $location"
		else
			PUBLIC_IP=`curl -s https://ipinfo.io/ip`
			location=`curl -s https://ipinfo.io/${PUBLIC_IP}/city`
			echo -e "\n	Your Location: $location"
		fi

		echo -n "	Enter Your Exact Address: "
		read exact
		echo -n "	Enter Your Contact Info (Mobile no.): "
		read phone
		echo ""
		echo -n "	Are you sure to order? ("y" to confirm): "
		read confirm
		if [[ "$confirm" == "y" ]]
		then
			
			dir_order="$PWD/restaurants/orders"
			if [ ! -d $dir_order ] 
			then
				mkdir $dir_order
			fi
			c1=`date +%d`
			c2=`date +%H`
			c3=`date +%M`
			today=`date`
			code="${c1}${c2}${c3}"
			item_price=`awk "NR==$or_cp" $PWD/restaurants/$RES.item`
			total_bill=`expr "$item_price" \* "$qty"`
			clear
			echo -e "\n	--> Please Wait <----- \n"
			sleep 1
			echo "	Code: $code | $RES : Total Bill - $total_bill | $location - $exact">> "$dir_order/orders"
			echo "$code">>"$dir_order/codes"
			echo " ">>"$dir_order/$code.txt"
			echo "	Order Details: $RES">>"$dir_order/$code.txt"
			echo "	------------------------">>"$dir_order/$code.txt"
			echo " ">>"$dir_order/$code.txt"
			echo "	Item Ordered: $item">>"$dir_order/$code.txt"
			echo "	Quantity Ordered: $qty">>"$dir_order/$code.txt"
			echo "	Total = $total_bill">>"$dir_order/$code.txt"
			echo "	------------------------">>"$dir_order/$code.txt"
			echo "	Order Location: $location, $exact">>"$dir_order/$code.txt"
			echo "	Order phone no: $phone">>"$dir_order/$code.txt"
			echo "	Order Date: $today">>"$dir_order/$code.txt"
			clear
			
			sleep 1
			echo -e "\n	Order Confirmed! \n"
			
		else
			clear
			sleep 1
			echo -e "\n	--> Cancelling Order ! <----- \n"
			sleep 1
			clear
		fi
		break
	fi
	done
	


elif [[ $choice == "3" ]]
then
	while true
	do
	clear
	echo -e "\n	All Orders \n	--------------- \n"
	#order_file=`cat order_file`
	order_file_dir="$PWD/restaurants/orders"
	if [ ! -d $order_file_dir ]
	then
		echo "	No orders done"
	else	
		order_file="$order_file_dir/orders"
		order_count=`wc --lines < $order_file`
		if [ "$order_count" == 0 ]
		then
			echo "	No orders done"
		
		else
			cat "$order_file"
		fi
	fi
	

	 
	echo -e "\n	0. Main Menu \n"
	echo -n "	Enter Order Code to View Details: "
	read ch_or
	ord_dir="$PWD/restaurants/orders/"
	ord_search="$(grep "$ch_or" $ord_dir/codes)"
	if [[ $ch_or == "0" ]]
	then
		clear
		echo -e "\n	Main Menu \n"
		break
	fi
	if [[ ! "$ord_search" == "$ch_or" ]]
	then
		clear
		sleep 1
		echo -e "\n	ERROR: Not in options  \n"
		sleep 1
		continue
	
	else
		while true
		do
		clear
		OR_LINE="$(grep -n "$ch_or" $PWD/restaurants/orders/codes | head -n 1 | cut -d: -f1)"
		if [[ -z "$OR_LINE" ]]
		then
			break
		fi
		
		echo " "
		or_file="$PWD/restaurants/orders/$ch_or.txt"
		cat $or_file
		echo -e "\n	Enter (x). Remove/Cancel Order  "
		echo -e "	0. Back \n"
		echo -n "	Enter Choice: "
		read sloption
		
		if [[ $sloption == "0" ]]
		then
			clear
			echo -e "\n	Going Back... \n"
			sleep 1
			clear
			break
		elif [[ $sloption == "x" ]]
		then
			clear
			echo -e "\n	Cancelling/Deleting......"
			sleep 1
			clear

			sed -i "$OR_LINE d" $PWD/restaurants/orders/codes
			sed -i "$OR_LINE d" $PWD/restaurants/orders/orders
			/bin/rm -f $PWD/restaurants/orders/$ch_or.txt
			
			clear
			echo -e "\n	Cancelling/Deleting Done......Please wait.."
			sleep 1
			clear
			
			break
			break
			
		
		else
			echo ""
			clear
			continue
		fi
		
		done
		

	fi
	done
		

elif [[ $choice == 4 ]]
then
	while true
	do
	clear
	echo -e "\n	Manage \n	--------------- \n"
	echo -e "	1. Manage Restaurants \n"
	echo -e "	0. Main Menu \n"
	echo  -n "	Enter your choice: "
	read choicem

	
	if [[ $choicem == "1" ]]
	then
	
		while true
		do
	

		clear
		echo -e "\n	Manage Restaurants \n	--------------- \n"
		echo -e "	1. Add Restaurants \n"
		echo -e "	2. Update Restaurants \n"
		echo -e "	3. Remove Restaurants \n"
		echo -e "	0. Back \n"
		echo  -n "	Enter your choice: "
		read choicemr
		if [[ $choicemr == "1" ]]
		then
			clear
			echo -e "\n	Manage Restaurants \n	--------------- \n"
			echo -n "	Enter Restaurants Name:  "
			read restaurant
			restaurant="${restaurant,,}"
   			restaurant=( $restaurant ) 
			restaurant="${restaurant[@]^}"
			directory="$PWD/restaurants/"
			restaurantsearch="${restaurant// /_}"
			search="$(grep "$restaurantsearch" $directory/restaurants)"
   			if [[ "$search" == "$restaurantsearch" ]]
   			then
   				echo -e "\n	Already Added! Press any key "
   				echo -n "	->"		
   				read any
   				clear
   				continue
   			fi
   			mkdir $directory
   			clear
   			echo -e "\n	$restaurant \n	--------------- \n"
   			echo -n "	Enter District Name:  "
   			#Adding District
   			read district
   			district="${district,,}"
   			district=( $district ) 
			district="${district[@]^}"
			dis_path="$PWD/restaurants/districts/"
			search2="$(grep "$district" $dis_path/restaurants/districts)"
   			if [[ "$search2" != "$district" ]] 
   			then
   				mkdir $dis_path
   				clear
   				count_dis=`wc --lines < $dis_path/dis_num`
   				count_dis2=`expr $count_dis + 1`
   				echo "	$count_dis2. $district">>"$dis_path/dis_num"
   				echo "$district">>"$dis_path/districts"
   				
   			
   				
   			fi
   			clear
   			
   			#Adding District Complete
   			echo -e "\n	$restaurant \n	--------------- \n"
   			echo -e "	District: $district \n"
   			echo " "
   			echo -n "	Popular Food Item Name (1):  "
   			read f1
   			re='^[0-9]+$'
   			while true
   			do
   			echo -n "	Price (1) :  "
   			read p1
   			if ! [[ $p1 =~ $re ]] ; then
   				echo -e "	Enter a valid number!"
   				continue
   			else
   				break
			fi
   			done
   			
   			echo " "
   			echo -n "	Popular Food Item Name (2):  "
   			read f2
   			while true
   			do
   			echo -n "	Price (2) :  "
   			read p2
   			if ! [[ $p1 =~ $re ]] ; then
   				echo -e "	Enter a valid number!"
   				continue
   			else
   				break
			fi
   			done
   			
   			echo " "
   			echo -n "	Popular Food Item Name (3):  "
   			read f3
   			while true
   			do
   			echo -n "	Price (3) :  "
   			read p3
   			if ! [[ $p1 =~ $re ]] ; then
   				echo -e "	Enter a valid number!"
   				continue
   			else
   				break
			fi
   			done
   			
   			echo " "
   			echo -n "	Popular Food Item Name (4):  "
   			read f4
   			while true
   			do
   			echo -n "	Price (4) :  "
   			read p4
   			if ! [[ $p1 =~ $re ]] ; then
   				echo -e "	Enter a valid number!"
   				continue
   			else
   				break
			fi
   			done
   			
   			echo " "
   			echo " "
   			echo -n "	Contact (Phone/Email) :  "
   			read contact
   			
   			restaurant_="${restaurant// /_}"
   			#restaurant_=$(echo "$restaurant__" | tr '[:lower:]' '[:upper:]') for searching
   			echo "	$restaurant">>"$directory/$restaurant_.txt"
   			echo "	====================">>"$directory/$restaurant_.txt"
   			echo "	">>"$directory/$restaurant_.txt"
   			
   			
   			echo "	Item 1: $f1 -> $p1 TAKA">>"$directory/$restaurant_.txt"
   			echo "	">>"$directory/$restaurant_.txt"
   			echo $p1>>"$directory/$restaurant_.item"
   			
   			echo "	Item 2: $f2 -> $p2 TAKA">>"$directory/$restaurant_.txt"
   			echo "	">>"$directory/$restaurant_.txt"
   			echo $p2>>"$directory/$restaurant_.item"
   			
   			echo "	Item 3: $f3 -> $p3 TAKA">>"$directory/$restaurant_.txt"
   			echo "	">>"$directory/$restaurant_.txt"
   			echo $p3>>"$directory/$restaurant_.item"
   			
   			echo "	Item 4: $f4 -> $p4 TAKA">>"$directory/$restaurant_.txt"
   			echo "	">>"$directory/$restaurant_.txt"
   			echo $p4>>"$directory/$restaurant_.item"
   			
   			echo "	----------------">>"$directory/$restaurant_.txt"
   			echo "	Contact Details : $contact">>"$directory/$restaurant_.txt"
   			echo "	Address : $district">>"$directory/$restaurant_.txt"
   			
   			count_res=`wc --lines < $directory/res_num`
   			count_res2=`expr $count_res + 1`
   			
   			echo "=> $restaurant">>"$directory/res_num"
   			echo "=> $restaurant ~ $district">>"$directory/res_num_dis"
   			echo "$district">>"$directory/list_dis"
   			echo "$restaurant_">>"$directory/restaurants"
   			echo "$restaurant_">>"$directory/$district.item"
   			count_res_list=`wc --lines < $directory/$district.lst`
   			count_res_list2=`expr $count_res_list + 1`
   			echo "=> $restaurant">>"$directory/$district.lst"
   			clear
   			sleep 1
   			echo -e "		Successfully Added! \n"
   			sleep 1
   			
   			
   			
   		elif [[ $choicemr == "2" ]]
   		then
   		clear
   		
   		while true
   		do
		echo -e "\n	Update Restaurants \n	--------------- \n"
		filedir="$PWD/restaurants"
		if [ ! -d $filedir ]
		then
			clear
			sleep 1
			echo -e "\n	No data available"
			sleep 1
			clear
			break
		else
			filepath="$filedir/res_num_dis"
			file_count=`wc --lines < $filepath`
		fi
		if [ "$file_count" == 0 ]
		then
			clear
			sleep 1
			echo -e "\n	No data available"
			sleep 1
			clear
			break
		
		else
			cat --number-nonblank  "$filepath"
			echo " "
			
		fi
		echo -e "	0. Go Back \n"
		
		echo  -n "	Enter Restaurant No. (Update): "
		read up_choice
		if [[ $up_choice == "0"  ]]
		then
			clear
			echo -e "\n	Going Back"
			sleep 1
			clear
			break
		fi
		
		RES2=`awk "NR==$up_choice" $PWD/restaurants/restaurants`
		if [[ -z "$RES2" ]]
		then
			clear
			echo -e "\n	ERROR: Not in options  \n"
			continue
	
		else
			while true
			do
			clear
			echo -e "\n	Update Restaurant \n	--------------- \n"
			resfile2="$PWD/restaurants/$RES2.txt"
			resfile2_item="$PWD/restaurants/$RES2.item"
			cat $resfile2
			echo ""
			echo  -e "	(For Complete Update, Please delete and add new one) \n"
			
			echo  -e "	1. Update Item 1"
			echo  -e "	2. Update Item 2"
			echo  -e "	3. Update Item 3"
			echo  -e "	4. Update Item 4"
			echo  -e "	5. Update Contact Details"
			echo  -e "	0. Go Back: "
			echo ""
			echo  -n "	Enter Your Choiche: "
			read up_choice2
			if [[ $up_choice2 == "0"  ]]
			then
				clear
				echo -e "\n	Going Back"
				sleep 1
				clear
				break
			fi
			if [[ $up_choice2 == "5"  ]]
			then
				clear
				sleep 1
				echo -e "\n	Update Restaurant \n	--------------- \n"
				echo -n "	Contact (Phone/Email) :  "
   				read u_contact
   				
   				sed -i '13d' $PWD/restaurants/$RES2.txt
   				sed "13i\	Contact Details : $u_contact" $PWD/restaurants/$RES2.txt > "$PWD/restaurants/temp"
   				cat "$PWD/restaurants/temp">$PWD/restaurants/$RES2.txt
   				clear
   				continue


				
			
			elif [[ $up_choice2 == "1"  ]]
			then
				clear
				sleep 1
				echo -e "\n	Update Restaurant \n	--------------- \n"
				echo -n "	Popular Food Item Name (1):  "
   				read f1
   				re='^[0-9]+$'
   				while true
   				do
   				echo -n "	Price (1) :  "
   				read p1
   				if ! [[ $p1 =~ $re ]] ; then
   					echo -e "	Enter a valid number!"
   					continue
   				else
   					break
				fi
   				done
   			
   				echo " "
   				#Remove Line 4 and write in line 4
   				sed -i '4d' $PWD/restaurants/$RES2.txt
   				sed "4i\	Item 1: $f1 -> $p1 TAKA" $PWD/restaurants/$RES2.txt > "$PWD/restaurants/temp"
   				cat "$PWD/restaurants/temp">$PWD/restaurants/$RES2.txt
   				sed -i '1d' $PWD/restaurants/$RES2.item
   				sed "1i$p1" $PWD/restaurants/$RES2.item > "$PWD/restaurants/temp"
   				cat "$PWD/restaurants/temp">$PWD/restaurants/$RES2.item
   				clear
   				continue
			
			elif [[ $up_choice2 == "2"  ]]
			then
				clear
				sleep 1
				echo -e "\n	Update Restaurant \n	--------------- \n"
				echo -n "	Popular Food Item Name (2):  "
   				read f2
   				re='^[0-9]+$'
   				while true
   				do
   				echo -n "	Price (2) :  "
   				read p2
   				if ! [[ $p2 =~ $re ]] ; then
   					echo -e "	Enter a valid number!"
   					continue
   				else
   					break
				fi
   				done
   			
   				echo " "
   				#Remove Line 6 and write in line 6
   				sed -i '6d' $PWD/restaurants/$RES2.txt
   				sed "6i\	Item 2: $f2 -> $p2 TAKA" $PWD/restaurants/$RES2.txt > "$PWD/restaurants/temp"
   				cat "$PWD/restaurants/temp">$PWD/restaurants/$RES2.txt
   				sed -i '2d' $PWD/restaurants/$RES2.item
   				sed "2i$p2" $PWD/restaurants/$RES2.item > "$PWD/restaurants/temp"
   				cat "$PWD/restaurants/temp">$PWD/restaurants/$RES2.item
   				clear
   				continue
			
			elif [[ $up_choice2 == "3"  ]]
			then
				clear
				sleep 1
				echo -e "\n	Update Restaurant \n	--------------- \n"
				echo -n "	Popular Food Item Name (3):  "
   				read f3
   				re='^[0-9]+$'
   				while true
   				do
   				echo -n "	Price (3) :  "
   				read p3
   				if ! [[ $p3 =~ $re ]] ; then
   					echo -e "	Enter a valid number!"
   					continue
   				else
   					break
				fi
   				done
   			
   				echo " "
   				#Remove Line 8 and write in line 8
   				sed -i '8d' $PWD/restaurants/$RES2.txt
   				sed "8i\	Item 3: $f3 -> $p3 TAKA" $PWD/restaurants/$RES2.txt > "$PWD/restaurants/temp"
   				cat "$PWD/restaurants/temp">$PWD/restaurants/$RES2.txt
   				sed -i '3d' $PWD/restaurants/$RES2.item
   				sed "3i$p3" $PWD/restaurants/$RES2.item > "$PWD/restaurants/temp"
   				cat "$PWD/restaurants/temp">$PWD/restaurants/$RES2.item
   				clear
   				continue
			
			elif [[ $up_choice2 == "4"  ]]
			then
				clear
				sleep 1
				echo -e "\n	Update Restaurant \n	--------------- \n"
				echo -n "	Popular Food Item Name (4):  "
   				read f4
   				re='^[0-9]+$'
   				while true
   				do
   				echo -n "	Price (4) :  "
   				read p4
   				if ! [[ $p4 =~ $re ]] ; then
   					echo -e "	Enter a valid number!"
   					continue
   				else
   					break
				fi
   				done
   			
   				echo " "
   				#Remove Line 10 and write in line 10
   				
   				sed -i '10d' $PWD/restaurants/$RES2.txt
   				sed "10i\	Item 4: $f4 -> $p4 TAKA" $PWD/restaurants/$RES2.txt > "$PWD/restaurants/temp"
   				cat "$PWD/restaurants/temp">$PWD/restaurants/$RES2.txt
   				sed -i '4d' $PWD/restaurants/$RES2.item
   				sed "4i$p4" $PWD/restaurants/$RES2.item > "$PWD/restaurants/temp"
   				cat "$PWD/restaurants/temp">$PWD/restaurants/$RES2.item
   				clear
   				continue
	
			else
				clear
				echo -e "\n	ERROR: Not in options  \n"
				sleep 1
				clear
				continue
				
			
			fi
			
			done
			
		
		fi
		done
		
		
		################ DELETE HERE #######
		
		elif [[ $choicemr == "3" ]]
		then
			while true 
			do
			clear
			echo -e "\n	Available Restaurants In Districts (For Delete) \n	--------------- \n"
			filedir="$PWD/restaurants"
			if [ ! -d $filedir ]
			then
				echo "	No data available"
				sleep 1
				break
			else
				filepath="$filedir/res_num_dis"
				file_count=`wc --lines < $filepath`
				if [ "$file_count" == 0 ]
				then
					echo "	No Data Available"
					sleep 1
					break
		
				else
					cat --number-nonblank  "$filepath"
					echo ""
					echo  -e "	0. Main Menu: "
					echo ""
					echo  -n "	Enter Restaurant No. To Delete: "
					read dlt_choice
					DLT_R=`awk "NR==$dlt_choice" $PWD/restaurants/restaurants`
					if [[ $dlt_choice == "0" ]]
					then
						clear
						break
					fi
					if [[ -z "$DLT_R" ]]
					then
						clear
						echo -e "\n	ERROR: Not in options  \n"
						sleep 1
						continue
	
					else
						#DELETE HERE
				
						clear
						echo -e "\n	Deleting......"
						sleep 1
						clear
					
						DIS=`awk "NR==$dlt_choice" $PWD/restaurants/list_dis`
						RES_IN_DIS="$(grep -n "$DIS" $PWD/restaurants/district.item | head -n 1 | cut -d: -f1)"
						
					
						sed -i "$RES_IN_DIS d" $PWD/restaurants/$DIS.item 
						sed -i "$RES_IN_DIS d" $PWD/restaurants/$DIS.lst 
						
						sed -i "$dlt_choice d" $PWD/restaurants/res_num 
						sed -i "$dlt_choice d" $PWD/restaurants/res_num_dis 
						sed -i "$dlt_choice d" $PWD/restaurants/list_dis 
						sed -i "$dlt_choice d" $PWD/restaurants/restaurants 
						
						/bin/rm -f $PWD/restaurants/$DLT_R.item
						/bin/rm -f $PWD/restaurants/$DLT_R.txt
						
						#rm -i $PWD/restaurants/a.txt
						clear
						echo -e "\n	Deleting Done......Please wait.."
						sleep 1
						clear
						continue
						
						
						
					fi
					
				fi
			fi
			done
		
   		
   		
   		
		elif [[ $choicemr == "0" ]]
		then
			clear
			echo -e "\n	Main Menu \n"
			break
	
		else
			clear
			echo -e "\n	ERROR: Not in options  \n"
			continue
		fi
		done
		
	

	
	elif [[ $choicem == "0" ]]
	then
		clear
		echo -e "\n	Main Menu \n"
		break
	
	else
		clear
		echo -e "\n	ERROR: Not in options  \n"
		continue
	fi
	done
	
	

elif [[ $choice == "0" ]]
then
	echo -e "	Exit Application"
	exit 1

else
	
	clear
	echo -e "\n	ERROR: Not in options \n"
	continue
	
fi
done

