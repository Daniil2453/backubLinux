#!/bin/bash

# Display the menu and get the user's choice
echo "What would you like to do?"
echo "1. Create a backup"
echo "2. Restore data from a backup"
echo "3. Backup ProjectTools"
read -p "Enter your choice [1-3]: " choice

# Validate the user's choice
if [[ $choice -lt 1 || $choice -gt 3 ]]; then
  echo "Invalid choice. Please enter a number between 1 and 3."
  exit 1
fi

# Get the backup path from the user
if [ $choice -eq 1 ]; then
  echo "Enter the path where you want to save the backup:"
  read -p "Path: " backup_path
fi

# Get the backup type from the user
if [ $choice -eq 1 ]; then
  echo "What type of backup do you want to create?"
  echo "1. System directories (/etc, /usr/local, /opt)"
  echo "2. Home directory (/home)"
  echo "3. KDE configuration (/home/$USER/.config/kde)"
  echo "4. Xfce configuration (/home/$USER/.config/xfce)"
  echo "5. GNOME configuration (/home/$USER/.config/gnome)"
  echo "6. Applications (from the store and deb packages)"
  echo "7. All of the above"
  read -p "Enter your choice [1-7]: " backup_type
fi

# Create the backup
if [ $choice -eq 1 ]; then
  # Create a directory for the backup with today's date and time
  backup_dir="$backup_path/$(date +%Y-%m-%d_%H-%M-%S)"
  mkdir -p "$backup_dir"

  case $backup_type in
    1)
      rsync -av --delete /etc /usr/local /opt "$backup_dir/system"
      ;;
    2)
      rsync -av --delete /home "$backup_dir/home"
      ;;
    3)
      rsync -av --delete /home/$USER/.config/kde "$backup_dir/kde-config"
      ;;
    4)
      rsync -av --delete /home/$USER/.config/xfce "$backup_dir/xfce-config"
      ;;
    5)
      rsync -av --delete /home/$USER/.config/gnome "$backup_dir/gnome-config"
      ;;
    6)
      dpkg --get-selections > "$backup_dir/packages.txt"
      ;;
    7)
      rsync -av --delete /etc /usr/local /opt "$backup_dir/system"
      rsync -av --delete /home "$backup_dir/home"
      rsync -av --delete /home/$USER/.config/kde "$backup_dir/kde-config"
      rsync -av --delete /home/$USER/.config/xfce "$backup_dir/xfce-config"
      rsync -av --delete /home/$USER/.config/gnome "$backup_dir/gnome-config"
      dpkg --get-selections > "$backup_dir/packages.txt"
      ;;
  esac

  echo "Backup successfully created at $backup_dir"
fi

# Restore data from the backup
if [ $choice -eq 2 ]; then
  echo "Enter the path to the backup you want to restore from:"
  read -p "Path: " backup_path

  # Restore the system directories
  rsync -av --delete "$backup_path/system" /

  # Restore the home directory
  rsync -av --delete "$backup_path/home" /

  # Restore the KDE configuration
  rsync -av --delete "$backup_path/kde-config" /home/$USER/.config/

  # Restore the Xfce configuration
  rsync -av --delete "$backup_path/xfce-config" /home/$USER/.config/

  # Restore the GNOME configuration
  rsync -av --delete "$backup_path/gnome-config" /home/$USER/.config/

  # Install the packages from the list
  dpkg --set-selections < "$backup_path/packages.txt"
  apt-get install -y --no-install-recommends --fix-broken

  echo "Data successfully restored from backup at $backup_path"
fi

# Backup ProjectTools
if [ $choice -eq 3 ]; then
  echo "What ProjectTool would you like to backup?"
  echo "1. PostgreSQL"
  echo "2. Visual Studio Code"
  echo "3. Nginx"
  echo "4. SSH"
  read -p "Enter your choice [1-4]: " project_tool

  case $project_tool in
    1)
      echo "Enter the path to the PostgreSQL data directory:"
      read -p "Path: " postgresql_data_dir

      # Backup the PostgreSQL data directory
      rsync -av --delete "$postgresql_data_dir" "$backup_path/postgresql"
      ;;
    2)
      echo "Enter the path to the Visual Studio Code settings directory:"
      read -p "Path: " vscode_settings_dir

      # Backup the Visual Studio Code settings directory
      rsync -av --delete "$vscode_settings_dir" "$backup_path/vscode"
      ;;
    3)
      echo "Enter the path to the Nginx configuration directory:"
      read -p "Path: " nginx_config_dir

      # Backup the Nginx configuration directory
      rsync -av --delete "$nginx_config_dir" "$backup_path/nginx"
      ;;
    4)
      echo "Enter the path to the SSH configuration directory:"
      read -p "Path: " ssh_config_dir

      # Backup the SSH configuration directory
      rsync -av --delete "$ssh_config_dir" "$backup_path/ssh"
      ;;
  esac

  echo "ProjectTool successfully backed up at $backup_path"
fi
