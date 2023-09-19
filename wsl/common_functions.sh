#!/bin/bash

# NOTE: This function assumes that drive_map, drive_map_work and drive_map_personal are already declared and populated
# Function to set drive_map based on SITUATION
set_drive_map() {
  # echo "Inside set_drive_map function"
  
  # Clear any existing drive_map
  unset drive_map
  declare -gA drive_map
  
  # echo "Current SITUATION: $SITUATION"
  
  # Deserialize the work-related associative arrays from strings
  if [[ -n "$DRIVE_MAP_WORK_STR" ]]; then
    eval "declare -A drive_map_work=${DRIVE_MAP_WORK_STR#*=}"
    # echo "Deserialized drive_map_work:"
    declare -p drive_map_work
  else
    echo "DRIVE_MAP_WORK_STR is empty."
  fi
  
  # Deserialize the personal-related associative arrays from strings
  if [[ -n "$DRIVE_MAP_PERSONAL_STR" ]]; then
    eval "declare -A drive_map_personal=${DRIVE_MAP_PERSONAL_STR#*=}"
    # echo "Deserialized drive_map_personal:"
    declare -p drive_map_personal
  else
    echo "DRIVE_MAP_PERSONAL_STR is empty."
  fi
  
  if [[ "$SITUATION" == "work" ]]; then
    echo "Setting work drives"
    for key in "${!drive_map_work[@]}"; do
      # Remove quotes from key
      clean_key=$(echo $key | tr -d '"')
      drive_map["$clean_key"]="${drive_map_work["$key"]}"
    done
  elif [[ "$SITUATION" == "personal" ]]; then
    echo "Setting personal drives"
    for key in "${!drive_map_personal[@]}"; do
      # Remove quotes from key
      clean_key=$(echo $key | tr -d '"')
      drive_map["$clean_key"]="${drive_map_personal["$key"]}"
    done
  else
    echo "SITUATION variable is not set to 'work' or 'personal'. drive_map will not be updated."
    return 1
  fi
  
  # echo "Final drive_map:"
  declare -p drive_map
}

# Function to convert paths between Linux and Windows
convert_path() {
	local src_path="$1"
	local target_os="$2"
	local format="$3" # This can be "Special" or "UNC"

	if [[ "$target_os" == "Windows" ]]; then
		if [[ "$src_path" == /mnt/* ]]; then
			# This is a mapped Windows drive, convert accordingly
			local drive_letter=$(echo "$src_path" | awk -F '/' '{print $3}')
			local remaining_path=$(echo "$src_path" | cut -d'/' -f4-)
			echo "${drive_letter}:\\$(echo $remaining_path | tr '/' '\\')"
		else
			# UNC path
			# TODO : prevent hardcode distro name, use some env or command
			local unc_path="\\\\wsl.localhost\\Debian${src_path//\//\\}"
			if [[ "$format" == "Special" ]]; then
				# Apply special formatting to UNC path by escaping all backslashes
				echo "${unc_path//\\/\\\\}"
			elif [[ "$format" == "UNC" ]]; then
				# Apply UNC formatting by only escaping the first two backslashes
				echo "\\\\"${unc_path:2}
			else
				echo "$unc_path"
			fi
		fi
	elif [[ "$target_os" == "Linux" ]]; then
		if [[ "$src_path" == \\\\wsl.localhost\\Debian* ]]; then
			echo "${src_path/\\\\wsl.localhost\\Debian/}" | tr '\\' '/'
		else
			local drive_letter=$(echo "$src_path" | awk -F '\\\\' '{print $1}')
			echo "${src_path/$drive_letter\\/\/mnt\/$drive_letter/}" | tr '\\' '/'
		fi
	else
		return 1
	fi
}
