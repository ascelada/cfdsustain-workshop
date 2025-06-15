#!/usr/bin/env bash
# install_openlb_wsl.sh
# --------------------------------------------------------------
# Installs dependencies and OpenLB on WSL Ubuntu 24.04, including:
#   • Linuxbrew + brew-installed Python 3
#   • gcc, make, git, OpenMPI, etc.
#   • ParaView 6.0.0-RC1 via wget
#   • Qt “xcb” dependencies (if Paraview fails to start)
#   • Clones OpenLB and applies cpu_gcc_openmpi.mk → config.mk
# --------------------------------------------------------------

set -e
set -o pipefail

echo "==> 1) Update apt repositories..."
sudo apt update

echo "==> 2) Install build tools, git, wget, tar, OpenMPI, etc. via apt..."
sudo apt install -y \
    build-essential \
    git \
    wget \
    tar \
    libopenmpi-dev \
    openmpi-bin \
    cmake \
    pkg-config

# ------------------------------------------------------------
# 3) Install Linuxbrew (if missing) & brew-installed Python 3
# ------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Linuxbrew not found—installing now..."
  # Install Linuxbrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH in this shell (adjust if your distro uses ~/.bash_profile or ~/.zshrc)
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  echo "==> Linuxbrew already installed."
fi

echo "==> 4) Using brew to install Python 3..."
sudo apt remove --purge python3
sudo apt autoremove 
brew update
brew install python3

# Make brew’s python3 the default in this session
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Confirm
echo "    • brew python3 location: $(which python3)"
echo "    • python3 version:       $(python3 --version)"
echo

# ------------------------------------------------------------
# 5) Download & Install ParaView 6.0.0-RC1 (via wget)
# ------------------------------------------------------------
PARAVIEW_VERSION="6.0.0-RC1"
PARAVIEW_DIR="/opt/paraview/${PARAVIEW_VERSION}"
PARAVIEW_TARBALL="ParaView-6.0.0-RC1-MPI-Linux-Python3.12-x86_64.tar.gz"
PARAVIEW_URL="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v6.0&type=binary&os=Linux&downloadFile=${PARAVIEW_TARBALL}"

echo "==> 6) Downloading ParaView ${PARAVIEW_VERSION}..."
cd /tmp

# Quote the URL so that '&' isn’t interpreted by bash
wget -O "${PARAVIEW_TARBALL}" \
  "${PARAVIEW_URL}"

echo "==> 7) Extracting ParaView into ${PARAVIEW_DIR}..."
sudo mkdir -p "${PARAVIEW_DIR}"
sudo tar --strip-components=1 -xzf "${PARAVIEW_TARBALL}" -C "${PARAVIEW_DIR}"

echo "==> 8) Creating symlink /usr/local/bin/paraview → ${PARAVIEW_DIR}/bin/paraview..."
sudo ln -sf "${PARAVIEW_DIR}/bin/paraview" /usr/local/bin/paraview

echo "==> 9) Cleaning up temporary tarball..."
rm -f "/tmp/${PARAVIEW_TARBALL}"
cd ~

# ------------------------------------------------------------
# 10) Quick check: try launching `paraview --help`. If it fails,
#     install the Qt “xcb” plugin dependencies.
# ------------------------------------------------------------
echo "==> 10) Verifying ParaView can start (checks for missing Qt plugins)..."
if ! paraview --help >/dev/null 2>&1; then
  echo "    • Paraview failed to run → installing Qt/XCB dependencies via apt..."
  sudo apt update
  sudo apt install -y \
    libxcb-cursor0 \
    libxcb-keysyms1 \
    libxcb-util1 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-render-util0 \
    libxcb-render0 \
    libxcb-shape0 \
    libxcb-sync1 \
    libxcb-xfixes0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libx11-xcb1 \
    libglu1-mesa \
    libgl1-mesa-dri
  echo "    • Qt/XCB dependencies installed."
else
  echo "    • Paraview launched successfully (Qt plugins OK)."
fi
echo

# ------------------------------------------------------------
# 11) Clone OpenLB repository (if missing) and set config.mk
# ------------------------------------------------------------
OPENLB_DIR="$HOME/openlb"
if [ -d "${OPENLB_DIR}" ]; then
  echo "==> 11) ${OPENLB_DIR} already exists; skipping clone."
else
  echo "==> 11) Cloning OpenLB into ${OPENLB_DIR}..."
  git clone https://gitlab.com/openlb/release.git "${OPENLB_DIR}"
fi

echo "==> 12) Overwriting OpenLB config.mk with cpu_gcc_openmpi.mk..."
cp -f "${OPENLB_DIR}/config/cpu_gcc_openmpi.mk" "${OPENLB_DIR}/config.mk"

echo
echo "============================================================="
echo "OpenLB installation complete!"
echo
echo "  • brew python3:  $(python3 --version)"
echo "  • ParaView:      /usr/local/bin/paraview  (version ${PARAVIEW_VERSION})"
echo "  • OpenMPI:       $(mpicxx --version | head -n1)"
echo "  • OpenLB root:   ${OPENLB_DIR} (using config.mk → cpu_gcc_openmpi.mk)"
echo "============================================================="


