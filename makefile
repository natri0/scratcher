CC := clang
LDFLAGS	:= -framework AppKit -framework Carbon

build/scratcher.app: build/scratcher
	@mkdir -p build/scratcher.app
	@cp build/scratcher build/scratcher.app/

build/scratcher: build/Keybind.o build/MyDelegate.o build/SettingsManager.o build/scratcher.o

build/%.o: %.m | build
	$(CC) $(OBJCFLAGS) -c $< -o $@

build:
	@mkdir -p build/
