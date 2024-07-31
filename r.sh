BUILD_NUMBER=100
ACTION=none


##1. Parse arguments
for i in "$@"; do
  case $i in
    --clean)
        ACTION=clean
        shift
        ;;
    --build)
        ACTION=build
        shift
        ;;
    --project) # default option
        ACTION=project
        shift
        ;;
    -bn=*|--buildNumber=*)
        BUILD_NUMBER="${i#*=}"
        shift
        ;;
    -*|--*)
        echo "Unknown option $i"
        exit 1
        ;;
    *)
        ;;
  esac
done

if [[ "$ACTION" = none ]]; then
    echo "No option specified"
    echo "You must specify one of:"
    echo " --clean      Clean project cache."
    echo " --build      Build project binary for AppStore upload. Specify '-bn=' option to setup build number."
    echo " --project    Create Xcode project for debuging app."
    exit 0
fi

##2. Prepare cache directory
mkdir -p "$HOME/elloapp-bazel-cache"

##3. Do working
if [[ "$ACTION" = clean ]]; then
    echo "Cleaning project cache.."
    rm -rf "$HOME/elloapp-bazel-cache"
    python3 build-system/Make/Make.py \
        --overrideXcodeVersion \
        clean

elif [[ "$ACTION" = build ]] ; then
    echo "Building" ${BUILD_NUMBER}
    echo "Latest build #$BUILD_NUMBER" > latest_build.txt

    mkdir build-output

    python3 build-system/Make/Make.py \
        --overrideXcodeVersion \
        --cacheDir="$HOME/elloapp-bazel-cache" \
        build \
        --configurationPath="build-system/appstore-configuration.json" \
        --codesigningInformationPath="build-system/example-configuration/provisioning" \
        --buildNumber ${BUILD_NUMBER} \
        --configuration release_universal \
        --outputBuildArtifactsPath="build-output" \
        && open "build-output/"
else
    echo "Generating project" ${BUILD_NUMBER}

    python3 build-system/Make/Make.py \
        --overrideXcodeVersion \
        --cacheDir="$HOME/elloapp-bazel-cache" \
        generateProject \
        --configurationPath="build-system/appstore-configuration.json" \
        --codesigningInformationPath="build-system/example-configuration/provisioning" \
        --buildNumber ${BUILD_NUMBER}
fi
