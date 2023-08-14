.DEFAULT_GOAL := install
txtr_dsk: pubspec.yaml
	fvm global 3.10.6
	flutter clean
	flutter build linux --release
install: txtr_dsk
	cp -r build/linux/x64/release/bundle/* ~/apps/sms
snapcraft: txtr_1.0.0_amd64.snap
	flutter clean
	snapcraft clean
	snapcraft --verbose
	sudo snap install ./txtr*.snap --devmode
