/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.sql {

  /// SQL type constants as defined by JDBC 1.x / SQL-92.
  ///
  /// Mirrors `java.sql.Types` (Java 1.1).
  ///
  /// - Since: JavaApi (Java 1.1)
  public enum Types {
    public static let BIT         : Int = -7
    public static let TINYINT     : Int =  -6
    public static let SMALLINT    : Int =   5
    public static let INTEGER     : Int =   4
    public static let BIGINT      : Int =  -5
    public static let FLOAT       : Int =   6
    public static let REAL        : Int =   7
    public static let DOUBLE      : Int =   8
    public static let NUMERIC     : Int =   2
    public static let DECIMAL     : Int =   3
    public static let CHAR        : Int =   1
    public static let VARCHAR     : Int =  12
    public static let LONGVARCHAR : Int =  -1
    public static let DATE        : Int =  91
    public static let TIME        : Int =  92
    public static let TIMESTAMP   : Int =  93
    public static let BINARY      : Int =  -2
    public static let VARBINARY   : Int =  -3
    public static let LONGVARBINARY : Int = -4
    public static let NULL        : Int =   0
    public static let OTHER       : Int = 1111
  }
}
