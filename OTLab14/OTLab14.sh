#!/bin/bash

lab_name="DNP3&WiresharkLab"
compose_file="${lab_name}.yml"

ot_container_name01="dnp3-outstation"
ot_container_name02="dnp3-master"
ews_container_name="otlab-student"

ubuntu_image="ubuntu:22.04"
kali_image="kalilinux/kali-rolling"

ews_ubuntu_image="lscr.io/linuxserver/webtop:ubuntu-xfce"
ews_kali_image="lscr.io/linuxserver/kali-linux:latest"

ews_install_packages="iputils-ping|nmap|net-tools|tcpdump|tshark|wireshark|iproute2|procps|iptables|sudo"

ews_web_port="3000"

lab_net01="dnp3-ot-net"
lab_net02="dnp3-corp-net"

# ----------------------------------------
# Function to display the banner
show_banner() {
    printf "\033[1;33m" # Yellow and bold
    echo " _____ _____ __        _   "
    echo "|     |_   _|  |   ___| |_ "
    echo "|  |  | | | |  |__| .'| . |"
    echo "|_____| |_| |_____|__,|___|"
    printf "\033[1;37m" # White and bold
    printf "Exercise:  14-DNP3 Protocol Emulation and Traffic Analysis Using Wireshark\n"
    printf "Version:   0.3\n"
    printf "Author:    rafaelfarias\n"
    printf "\033[0m" # Reset all styles
    echo ""
}

# ----------------------------------------
# Function to generate Docker Compose file
generate_compose_file() {
    local ews_image="$1"

    cat > "$compose_file" <<EOF
services:
  $ot_container_name01:
    image: $ubuntu_image
    container_name: $ot_container_name01
    hostname: $ot_container_name01
    mac_address: 00:1C:06:D3:01:01
    networks:
      $lab_net01:
        ipv4_address: 192.168.20.10
    cap_add:
      - NET_ADMIN
      - NET_RAW
    privileged: true
    command: >
      bash -c '
        apt update &&
        apt install -y python3 python3-pip iproute2 &&
        pip install dnp3-python &&
        ip route add 192.168.21.0/24 via 192.168.20.100 &&
        printf "%s\n" \
"from dnp3_python.dnp3station.outstation import MyOutStation" \
"from pydnp3 import opendnp3" \
"import time" \
"import random" \
"" \
"print(\"[OUTSTATION] Initializing DNP3 outstation on port 20000...\")" \
"outstation = MyOutStation(" \
"    outstation_ip=\"0.0.0.0\"," \
"    port=20000," \
"    master_id=2," \
"    outstation_id=1" \
")" \
"outstation.start()" \
"print(\"[OUTSTATION] Running. Waiting for master connections...\")" \
"" \
"i = 0" \
"while True:" \
"    voltage = round(random.uniform(110.0, 130.0), 2)" \
"    current = round(random.uniform(0.5, 15.0), 2)" \
"    breaker_open = bool(i % 20 == 0)" \
"    outstation.apply_update(opendnp3.Analog(value=voltage), 0)" \
"    outstation.apply_update(opendnp3.Analog(value=current), 1)" \
"    outstation.apply_update(opendnp3.Binary(value=breaker_open), 0)" \
"    print(f\"[OUTSTATION] Update #{i}: Voltage={voltage}V, Current={current}A, BreakerOpen={breaker_open}\")" \
"    i += 1" \
"    time.sleep(5)" \
> /outstation.py &&
        python3 /outstation.py'
    ports:
      - "20000:20000"

  $ot_container_name02:
    image: $ubuntu_image
    container_name: $ot_container_name02
    hostname: $ot_container_name02
    mac_address: 00:1C:06:D3:01:02
    networks:
      $lab_net02:
        ipv4_address: 192.168.21.20
    cap_add:
      - NET_ADMIN
      - NET_RAW
    privileged: true
    command: >
      bash -c '
        apt update &&
        apt install -y python3 python3-pip netcat-openbsd iproute2 &&
        pip install dnp3-python &&
        ip route replace default via 192.168.21.100 &&
        printf "%s\n" \
"from dnp3_python.dnp3station.master import MyMaster" \
"from pydnp3 import opendnp3" \
"import time" \
"" \
"print(\"[MASTER] Initializing DNP3 master...\")" \
"master = MyMaster(" \
"    master_ip=\"0.0.0.0\"," \
"    outstation_ip=\"192.168.20.10\"," \
"    port=20000," \
"    master_id=2," \
"    outstation_id=1" \
")" \
"master.start()" \
"print(\"[MASTER] Connected to outstation at 192.168.20.10:20000\")" \
"" \
"while True:" \
"    try:" \
"        analog_data = master.get_db_by_group_variation(group=30, variation=6)" \
"        binary_data = master.get_db_by_group_variation(group=1, variation=2)" \
"        print(f\"[MASTER] Analog readings: {analog_data}\")" \
"        print(f\"[MASTER] Binary readings: {binary_data}\")" \
"    except Exception as e:" \
"        print(f\"[MASTER] Poll error: {e}\")" \
"    time.sleep(10)" \
> /master.py &&
        echo "[MASTER] Waiting for outstation to start. . ." &&
        until nc -z 192.168.20.10 20000; do sleep 2; done &&
        echo "[MASTER] Outstation is up. Starting master. . ." &&
        sleep 3 &&
        python3 /master.py'

  $ews_container_name:
    image: $ews_image
    container_name: $ews_container_name
    hostname: $ews_container_name
    environment:
      - PUID=0
      - PGID=0
      - TZ=Etc/UTC
      - TITLE=OTLab Student
      - DOCKER_MODS=linuxserver/mods:universal-package-install
      - INSTALL_PACKAGES=$ews_install_packages
      - DEBIAN_FRONTEND=noninteractive
    volumes:
      - otlab-student-config:/config
    ports:
      - "$ews_web_port:3000"
    sysctls:
      - net.ipv4.ip_forward=1
    networks:
      $lab_net01:
        ipv4_address: 192.168.20.100
      $lab_net02:
        ipv4_address: 192.168.21.100
    cap_add:
      - NET_ADMIN
      - NET_RAW
    privileged: true
    shm_size: "1gb"
    restart: unless-stopped

volumes:
  otlab-student-config:

networks:
  $lab_net01:
    name: $lab_net01
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.20.0/24

  $lab_net02:
    name: $lab_net02
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.21.0/24
EOF
}

# ----------------------------------------
# Environment detection
# Cross-bridge routing between two Docker bridges requires kernel-level tweaks
# only on WSL2, where the default sysctl/iptables policies block forwarded
# traffic. On native Linux and macOS Docker Desktop the defaults work as-is.
detect_environment() {
    is_wsl=0
    is_linux=0
    is_macos=0

    case "$(uname -s)" in
        Linux*)
            is_linux=1
            if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
                is_wsl=1
            fi
            ;;
        Darwin*)
            is_macos=1
            ;;
    esac
}

# ----------------------------------------
# Apply cross-bridge forwarding rules (WSL only)
apply_cross_bridge_rules() {
    if [ "$is_wsl" -ne 1 ]; then
        return 0
    fi

    if ! command -v sudo >/dev/null 2>&1 || ! command -v iptables >/dev/null 2>&1; then
        printf "\033[33m[Warning]\033[0m WSL detected but 'sudo' or 'iptables' missing.\n"
        printf "\033[33m[Warning]\033[0m Cross-bridge traffic between OT and corp networks may not work.\n"
        return 0
    fi

    printf "\033[1;33m[Working]\033[0m WSL detected — applying cross-bridge routing rules (sudo required). . .\n"
    sudo sysctl -w net.bridge.bridge-nf-call-iptables=0 >/dev/null 2>&1
    sudo iptables -I DOCKER-USER -s 192.168.20.0/24 -d 192.168.21.0/24 -j ACCEPT 2>/dev/null
    sudo iptables -I DOCKER-USER -s 192.168.21.0/24 -d 192.168.20.0/24 -j ACCEPT 2>/dev/null
}

# ----------------------------------------
# Revert cross-bridge forwarding rules (WSL only)
revert_cross_bridge_rules() {
    if [ "$is_wsl" -ne 1 ]; then
        return 0
    fi

    if ! command -v sudo >/dev/null 2>&1 || ! command -v iptables >/dev/null 2>&1; then
        return 0
    fi

    printf "\033[1;33m[Working]\033[0m Reverting cross-bridge routing rules (sudo required). . .\n"
    sudo sysctl -w net.bridge.bridge-nf-call-iptables=1 >/dev/null 2>&1
    sudo iptables -D DOCKER-USER -s 192.168.20.0/24 -d 192.168.21.0/24 -j ACCEPT 2>/dev/null
    sudo iptables -D DOCKER-USER -s 192.168.21.0/24 -d 192.168.20.0/24 -j ACCEPT 2>/dev/null
}

# ----------------------------------------
# System requirements check
check_requirements() {
    error_flag=0

    if ! command -v docker >/dev/null 2>&1; then
        printf "\033[31m[Error]\033[0m Docker is not installed on this system.\n"
        error_flag=1
    elif ! docker info >/dev/null 2>&1; then
        printf "\033[31m[Error]\033[0m Docker is installed, but not accessible.\n"
        error_flag=1
    fi

    if command -v docker-compose >/dev/null 2>&1; then
        DOCKER_COMPOSE_CMD="docker-compose"
    elif docker compose version >/dev/null 2>&1; then
        DOCKER_COMPOSE_CMD="docker compose"
    else
        printf "\033[31m[Error]\033[0m Docker Compose is not installed.\n"
        error_flag=1
    fi

    if [ "$error_flag" -eq 1 ]; then
        printf "\033[31m✘ The $lab_name system requirements check failed.\033[0m\n"
        exit 1
    fi
}

# ----------------------------------------
# Print noVNC access info after start
print_access_info() {
    printf "\n\033[1;36m[Info]\033[0m Student desktop (noVNC) available at:\n"
    printf "       \033[1;37mhttp://localhost:%s/\033[0m\n" "$ews_web_port"
    printf "\033[1;36m[Info]\033[0m First boot installs lab tools (wireshark, nmap, ...).\n"
    printf "       This may take 1–3 minutes — refresh the page if it is not ready.\n"
    printf "\033[1;36m[Info]\033[0m For a CLI shell inside the student container, run: %s -run\n\n" "$0"
}

# ----------------------------------------
# Function to check if a container exists
container_exists() {
    docker ps -a --format '{{.Names}}' | grep -q "$1"
}

# ----------------------------------------
# Command handling
case "$1" in
    -start)
        show_banner
        distro="${2:-ubuntu}"

        if [[ "$distro" == "kali" ]]; then
            selected_image="$ews_kali_image"
        elif [[ "$distro" == "ubuntu" ]]; then
            selected_image="$ews_ubuntu_image"
        else
            printf "\033[31m[Error]\033[0m Invalid distro. Please use 'kali' or 'ubuntu'.\n"
            exit 1
        fi

        check_requirements
        detect_environment
        printf "\033[1;33m[Working]\033[0m Starting $lab_name. . .\n"
        generate_compose_file "$selected_image"
        $DOCKER_COMPOSE_CMD -f "$compose_file" up -d
        if [ $? -eq 0 ]; then
            apply_cross_bridge_rules
            printf "\033[32m✔ $lab_name started.\033[0m\n"
            print_access_info
        else
            printf "\033[31m✘ $lab_name failed to start.\033[0m\n"
            exit 1
        fi
        ;;
    -stop)
        show_banner
        if container_exists "$ot_container_name01" || container_exists "$ot_container_name02" || container_exists "$ews_container_name"; then
            check_requirements
            printf "\033[1;33m[Working]\033[0m Stopping $lab_name. . .\n"
            $DOCKER_COMPOSE_CMD -f "$compose_file" stop
            printf "\033[32m✔ $lab_name stopped.\033[0m\n"
        else
            printf "\033[34m[Information]\033[0m No containers to stop.\n"
            exit 1
        fi
        ;;
    -clean)
        show_banner
        if container_exists "$ot_container_name01" || container_exists "$ot_container_name02" || container_exists "$ews_container_name"; then
            check_requirements
            detect_environment
            printf "\033[1;33m[Working]\033[0m Cleaning up all $lab_name resources. . .\n"
            revert_cross_bridge_rules
            $DOCKER_COMPOSE_CMD -f "$compose_file" down -v
            docker network rm "$lab_net01" "$lab_net02" 2>/dev/null
            rm -f "$compose_file"
            printf "\033[32m✔ All $lab_name resources removed.\033[0m\n"
        else
             printf "\033[34m[Information]\033[0m No containers found to clean.\n"
             exit 1
        fi
        ;;
    -run)
        show_banner
        if container_exists "$ews_container_name"; then
            check_requirements
            printf "\033[1;33m[Working]\033[0m Accessing $ews_container_name terminal. . .\n"
            docker exec -it "$ews_container_name" bash
        else
            printf "\033[31m[Error]\033[0m Container $ews_container_name not found.\n"
            exit 1
        fi
        ;;
    -web)
        show_banner
        if container_exists "$ews_container_name"; then
            print_access_info
        else
            printf "\033[31m[Error]\033[0m Container $ews_container_name not found.\n"
            exit 1
        fi
        ;;
    -restart)
        show_banner
        check_requirements
        if [ ! -f "$compose_file" ]; then
            printf "\033[31m[Error]\033[0m Cannot restart: $compose_file not found.\n"
            exit 1
        fi

        printf "\033[1;33m[Working]\033[0m Restarting $lab_name. . .\n"
        $DOCKER_COMPOSE_CMD -f "$compose_file" up -d
        if [ $? -eq 0 ]; then
            printf "\033[32m✔ $lab_name restarted.\033[0m\n"
            print_access_info
        else
            printf "\033[31m✘ $lab_name failed to restart.\033[0m\n"
            exit 1
        fi
        ;;
    -status)
        show_banner
        check_requirements
        $DOCKER_COMPOSE_CMD -f "$compose_file" ps
        ;;
    *)
        show_banner
        echo "Usage: $0 -start [kali|ubuntu] | -stop | -clean | -run | -web | -restart | -status"
        echo ""
        echo "  -start     Start the $lab_name environment using the specified distro (default: ubuntu)"
        echo "             ubuntu -> $ews_ubuntu_image"
        echo "             kali   -> $ews_kali_image"
        echo "             Student desktop is available at http://localhost:$ews_web_port/"
        echo "  -run       Open a CLI terminal inside the $ews_container_name container"
        echo "  -web       Print the noVNC URL to access the student desktop"
        echo "  -clean     Remove containers, volumes, and network"
        echo "  -stop      Stop all containers"
        echo "  -restart   Restart previously stopped containers"
        echo "  -status    Show current containers status"
        exit 1
        ;;
esac
