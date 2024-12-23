url="https://github.com/bytium/vm-host-modules"
branch="17.6.1"

echo "VMware Workstation host modules compiler script"
echo "Using repo '$(echo $url | sed 's/https:\/\/github.com\///')'"

workdir="/tmp"
repo=$(basename $url)

# check if run as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: Run this script as root"
    exit 1
fi

# clean previous
if [[ -d "$workdir/$repo" ]]; then
    rm -rf "$workdir/$repo" >/dev/null
fi

# cloning from url
git -C "$workdir" clone --branch $branch --depth 1 $url >/dev/null

cd $workdir/$repo

# compiling
make >/dev/null
make install >/dev/null

# cleaning
rm -rf "$workdir/$repo" >/dev/null
