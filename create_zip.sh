mkdir -p "${WORK_DIR}"
mkdir -p "${OUT_DIR}"

VERSION=$(cat "${WORK_DIR}/version.txt")

FINAL_NAME="${NAME}-${VERSION}"
OUT_DIR_PATH="${OUT_DIR}/${FINAL_NAME}"
OUT_ARCHIVE_PATH="${OUT_DIR_PATH}.zip"

FORCE_REBUILD_DIR="false"
MAKE_ZIP="false"

for arg in "$@"; do
  if [ "$arg" = "--force-rebuild-dir" ]; then
    FORCE_REBUILD_DIR="true"
  elif [ "$arg" = "--zip" ]; then
    if [ ! -d "${OUT_ARCHIVE_PATH}" ] || [ "${FORCE_REBUILD_DIR}" = "true" ]; then
        MAKE_ZIP="true"
    fi
  elif [ "$arg" = "--force-rebuild-zip" ]; then
    MAKE_ZIP="true"
    if [ ! -d "${OUT_DIR_PATH}" ]; then
        FORCE_REBUILD_DIR="true"
    fi
  fi
done

if [ -n "${GITHUB_OUTPUT+isset}" ]; then
    echo "VERSION=${VERSION}" >> $GITHUB_OUTPUT
fi

if [ ! -d "${OUT_DIR_PATH}" ] || [ "${FORCE_REBUILD_DIR}" = "true" ]; then
    echo "Building resourcepack directory..."

    if [ -d "${OUT_DIR_PATH}" ]; then
        rm -r ${OUT_DIR_PATH}
    fi

    mkdir -p "${OUT_DIR_PATH}"
    cp -rT "${WORK_DIR}/pack" "${OUT_DIR_PATH}"

    find "${OUT_DIR_PATH}" -type f \
    \( ! -name "*.png" \
    -a ! -name "*.mcmeta" \
    -a ! -name "*.json" \
    -a ! -name "*.dat" \
    -a ! -name "*.lang" \
    -a ! -name "*.ttf" \
    -a ! -name "*.mcfunction" \
    -a ! -name "*.ogg" \
    -a ! -name "*.model" \
    \) -exec rm {} \;

    find "${OUT_DIR_PATH}" -maxdepth 1 -type f -exec sed -i "s/%version%/${VERSION}/g" {} +

    echo "Resourcepack built at ${OUT_DIR_PATH}"
fi

if [ "${MAKE_ZIP}" = "true" ]; then
    cd ${OUT_DIR_PATH} && zip -r ${OUT_ARCHIVE_PATH} .
    echo "Archive created at ${OUT_ARCHIVE_PATH}"
fi
