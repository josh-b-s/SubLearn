/// True for CJK ideographs, the same set the Swift app treats as Chinese text.
bool isHanRune(int r) =>
    (r >= 0x4E00 && r <= 0x9FFF) ||
    (r >= 0x3400 && r <= 0x4DBF) ||
    (r >= 0x20000 && r <= 0x323AF) ||
    (r >= 0xF900 && r <= 0xFAFF) ||
    r == 0x3007;

bool isHanChar(String char) => char.runes.any(isHanRune);

bool isAllHan(String text) => text.isNotEmpty && text.runes.every(isHanRune);

int runeLength(String text) => text.runes.length;
