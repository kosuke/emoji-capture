MKDIR_P = mkdir -p
SWIFTC=xcrun -sdk macosx swiftc
TARGET=x86_64-apple-macosx10.10
OUTPUT=build/emojicapture
SOURCE=EmojiCapture/EmojiHelper.swift EmojiCapture/main.swift

$(OUTPUT): $(SOURCE) 
	mkdir -p build 
	$(SWIFTC) -target $(TARGET) $(SOURCE) -o $(OUTPUT)

clean:
	$(RM) $(OUTPUT)
