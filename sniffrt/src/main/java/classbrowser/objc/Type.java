package classbrowser.objc;

public enum Type {
    CHAR,
    INT,
    SHORT,
    LONG,
    LONG_LONG,
    UNSIGNED_CHAR,
    UNSIGNED_INT,
    UNSIGNED_SHORT,
    UNSIGNED_LONG,
    UNSIGNED_LONG_LONG,
    FLOAT,
    DOUBLE,
    BOOL,
    VOID,
    CHAR_STR,
    ID,
    CLASS,
    SEL,
    ARRAY,
    STRUCT,
    UNION,
    BIT_FIELD,
    PTR,
    UNKNOWN;


    public static Type fromEncoded(String enc) {

        switch (enc) {
            case "c": return CHAR;
            case "i": return INT;
            case "s": return SHORT;
            case "l": return LONG;
            case "q": return LONG;
            /** TBD */
            case "*": return CHAR_STR;
            case "@": return ID;
            case "#": return CLASS;
            case ":": return SEL;

            default: return UNKNOWN; // TODO: implement full list
        }

    }
}
