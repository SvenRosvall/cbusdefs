OUTPUT=cbusdefsenums.cs
echo "Generating $OUTPUT"
# first output the header stuff
cat << EOF > $OUTPUT
/* DO NOT EDIT THIS FILE.
 * This file is automatically generated by $0 from cbusdefs.csv
 */ 

namespace Merg.Cbus
{

EOF

# output the comments
grep '^comment' cbusdefs.csv | cut -f2- -d , | sed 's!^!    // !' |sed 's!,!!' | sed 's!,!!' >> $OUTPUT

cat << EOF >> $OUTPUT

EOF

for class in $(cat cbusdefs.csv|cut -f1 -d ,|grep -v comment|sort|uniq)
do
	echo "           CbusDefs.$class"

	cat << EOF >> $OUTPUT
	/// <summary>
EOF

	while IFS="," read type	name value comment 
	do
		if [ "$type" = $class ]; then
			if [ "X$name" = "X" ]; then
				if [ "X$comment" != "X" ]; then
					echo -e "\t/// $value$comment" 
					break
				fi
			fi
			echo -e "\t/// class: $class"
		fi
	done < cbusdefs.csv >> $OUTPUT

	enum="$(sed -e 's/Cbus//' <<< $class)"

	cat << EOF >> $OUTPUT
	/// </summary>
	public enum $enum
	{
EOF

	# now output the actual contents
	while IFS="," read type	name value comment 
	do
		if [ "$type" = $class ]; then
#			if [ "X$name" = "X" ]; then
#				if [ "X$comment" != "X" ]; then
#					echo -e "\t\t// $value$comment" 
#				fi
#			else
			if [ "X$name" != "X" ]; then
				#rewrite $name to match C# standards and remove redundancy
				if [[ $name == *"_"* ]]; then
					IFS="_" read -ra typename <<< $name

					name="$(sed -e 's/^SASP_//' -e 's/^CMDERR_//' -e 's/^PAR_//' -e 's/^ERR_//' -e 's/^MANU_//' -e 's/^MTYP_//' -e 's/^OPC_//' -e 's/^PF_//' -e 's/^PAR_//' -e 's/^CPUM_//' -e 's/^SSTAT_//' -e 's/^TMOD_//' <<< $name)"
					

					name="$(sed -e 's/\(.\)\([^_]*\)_\{0,1\}/\U\1\L\2/g' <<< $name)"
				fi
				if [ "X$comment" != "X" ]; then
					echo -e "\t\t/// <summary>"
					echo -e "\t\t/// $comment"
					echo -e "\t\t/// </summary>"
				fi
				echo -e "\t\t$name = $value," 
			fi
		fi
	done < cbusdefs.csv >> $OUTPUT

	cat << EOF >> $OUTPUT
	}

EOF
done

# finally output the trailer stuff
cat << EOF >> $OUTPUT
}
EOF
