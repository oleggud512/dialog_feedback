gen:
	dart run build_runner build

gen_migration:
	dart run drift_dev make-migrations

clean:
	flutter clean
	flutter pub get
