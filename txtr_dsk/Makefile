.DEFAULT_GOAL := install
.PHONY: linux
txtr_dsk: pubspec.yaml
	fvm global 3.10.6
	flutter clean
	flutter build linux --release
install: txtr_dsk
	cp -r build/linux/x64/release/bundle/* ~/apps/sms
linux:
	chmod 664 ./snap/gui/txtr_icon.png
	snapcraft --verbose
	sudo snap install ./txtr*.snap --devmode
clean:
	flutter clean
	snapcraft clean
	flutter packages upgrade
windows:
	iscc windows\txtr.iss
