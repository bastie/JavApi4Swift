/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.awt.event {

  public class KeyEvent: InputEvent, @unchecked Sendable {

    public static let KEY_FIRST   = 400
    public static let KEY_LAST    = 402
    public static let KEY_TYPED   = 400
    public static let KEY_PRESSED = 401
    public static let KEY_RELEASED = 402

    public static let CHAR_UNDEFINED: Character = "\u{FFFF}"
    public static let VK_UNDEFINED   = 0

    // Alphanumeric
    public static let VK_A = 65;  public static let VK_B = 66
    public static let VK_C = 67;  public static let VK_D = 68
    public static let VK_E = 69;  public static let VK_F = 70
    public static let VK_G = 71;  public static let VK_H = 72
    public static let VK_I = 73;  public static let VK_J = 74
    public static let VK_K = 75;  public static let VK_L = 76
    public static let VK_M = 77;  public static let VK_N = 78
    public static let VK_O = 79;  public static let VK_P = 80
    public static let VK_Q = 81;  public static let VK_R = 82
    public static let VK_S = 83;  public static let VK_T = 84
    public static let VK_U = 85;  public static let VK_V = 86
    public static let VK_W = 87;  public static let VK_X = 88
    public static let VK_Y = 89;  public static let VK_Z = 90

    public static let VK_0 = 48;  public static let VK_1 = 49
    public static let VK_2 = 50;  public static let VK_3 = 51
    public static let VK_4 = 52;  public static let VK_5 = 53
    public static let VK_6 = 54;  public static let VK_7 = 55
    public static let VK_8 = 56;  public static let VK_9 = 57

    // Control
    public static let VK_ENTER     = 10
    public static let VK_BACK_SPACE = 8
    public static let VK_TAB       = 9
    public static let VK_CANCEL    = 3
    public static let VK_CLEAR     = 12
    public static let VK_SHIFT     = 16
    public static let VK_CONTROL   = 17
    public static let VK_ALT       = 18
    public static let VK_PAUSE     = 19
    public static let VK_CAPS_LOCK = 20
    public static let VK_ESCAPE    = 27
    public static let VK_SPACE     = 32
    public static let VK_DELETE    = 127

    // Navigation
    public static let VK_PAGE_UP   = 33
    public static let VK_PAGE_DOWN = 34
    public static let VK_END       = 35
    public static let VK_HOME      = 36
    public static let VK_LEFT      = 37
    public static let VK_UP        = 38
    public static let VK_RIGHT     = 39
    public static let VK_DOWN      = 40
    public static let VK_INSERT    = 155

    // Function keys
    public static let VK_F1  = 112; public static let VK_F2  = 113
    public static let VK_F3  = 114; public static let VK_F4  = 115
    public static let VK_F5  = 116; public static let VK_F6  = 117
    public static let VK_F7  = 118; public static let VK_F8  = 119
    public static let VK_F9  = 120; public static let VK_F10 = 121
    public static let VK_F11 = 122; public static let VK_F12 = 123

    // Punctuation / symbols
    public static let VK_COMMA        = 44
    public static let VK_PERIOD       = 46
    public static let VK_SLASH        = 47
    public static let VK_SEMICOLON    = 59
    public static let VK_EQUALS       = 61
    public static let VK_OPEN_BRACKET  = 91
    public static let VK_BACK_SLASH   = 92
    public static let VK_CLOSE_BRACKET = 93
    public static let VK_MINUS        = 45
    public static let VK_QUOTE        = 222
    public static let VK_BACK_QUOTE   = 192

    // Misc
    public static let VK_META        = 157
    public static let VK_ALT_GRAPH   = 65406
    public static let VK_NUM_LOCK    = 144
    public static let VK_SCROLL_LOCK = 145
    public static let VK_WINDOWS     = 524
    public static let VK_CONTEXT_MENU = 525

    // -------------------------------------------------------------------------

    public let keyCode: Int
    public let keyChar: Character

    public init(_ source: java.awt.Component, _ id: Int,
                _ when: Int64, _ modifiers: Int,
                _ keyCode: Int, _ keyChar: Character) {
      self.keyCode = keyCode
      self.keyChar = keyChar
      super.init(source, id, when, modifiers)
    }

    public func getKeyCode() -> Int       { keyCode }
    public func getKeyChar() -> Character { keyChar  }
  }
}
