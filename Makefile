APPS := /Applications
BUILD_DIR := "build"

all: clean release install

clean:
	rm -rf $(BUILD_DIR)

release:
	xcodebuild -parallelizeTargets -sdk macosx -scheme RoutesViewer -configuration Release -derivedDataPath $(BUILD_DIR) -IDECustomBuildProductsPath="" -IDECustomBuildIntermediatesPath="" clean build

install:
	cp -R $(BUILD_DIR)/Build/Products/Release/RoutesViewer.app $(APPS)