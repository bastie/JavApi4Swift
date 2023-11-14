/*
 * SPDX-FileCopyrightText: 2015 - Doug Richardson
 * SPDX-FileCopyrightText: 2023 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: Unlicense
 */


extension java.util {
  ///
  /// Base64 Alphabet to use during encoding.
  ///
  /// - Standard: The standard Base64 encoding, defined in RFC 4648 section 4.
  /// - URLAndFilenameSafe: The base64url encoding, defined in RFC 4648 section 5.
  ///
  public enum Alphabet {
    /// The standard Base64 alphabet
    case Standard
    
    /// The URL and Filename Safe Base64 alphabet
    case URLAndFilenameSafe
  }

}

extension java.util.Base64 {


  //
  //  Alphabets.swift
  //  SwiftyBase64
  //
  //  Created by Doug Richardson on 8/7/15.
  //  Modify ⁴JavApi by Sebastian Ritter
  //
  
  // Note the tables contain 65 characters: 64 to do the translation and 1 more for the padding
  // character used in each alphabet.
  
  /// Standard Base64 encoding table.
  static let StandardAlphabet : [UInt8] = [
    65, // 0=A
    66, // 1=B
    67, // 2=C
    68, // 3=D
    69, // 4=E
    70, // 5=F
    71, // 6=G
    72, // 7=H
    73, // 8=I
    74, // 9=J
    75, // 10=K
    76, // 11=L
    77, // 12=M
    78, // 13=N
    79, // 14=O
    80, // 15=P
    81, // 16=Q
    82, // 17=R
    83, // 18=S
    84, // 19=T
    85, // 20=U
    86, // 21=V
    87, // 22=W
    88, // 23=X
    89, // 24=Y
    90, // 25=Z
    97, // 26=a
    98, // 27=b
    99, // 28=c
    100, // 29=d
    101, // 30=e
    102, // 31=f
    103, // 32=g
    104, // 33=h
    105, // 34=i
    106, // 35=j
    107, // 36=k
    108, // 37=l
    109, // 38=m
    110, // 39=n
    111, // 40=o
    112, // 41=p
    113, // 42=q
    114, // 43=r
    115, // 44=s
    116, // 45=t
    117, // 46=u
    118, // 47=v
    119, // 48=w
    120, // 49=x
    121, // 50=y
    122, // 51=z
    48, // 52=0
    49, // 53=1
    50, // 54=2
    51, // 55=3
    52, // 56=4
    53, // 57=5
    54, // 58=6
    55, // 59=7
    56, // 60=8
    57, // 61=9
    43, // 62=+
    47, // 63=/
    // PADDING FOLLOWS, not used during lookups
    61, // 64==
  ]
  
  /// URL and Filename Safe Base64 encoding table.
  static let URLAndFilenameSafeAlphabet : [UInt8] = [
    65, // 0=A
    66, // 1=B
    67, // 2=C
    68, // 3=D
    69, // 4=E
    70, // 5=F
    71, // 6=G
    72, // 7=H
    73, // 8=I
    74, // 9=J
    75, // 10=K
    76, // 11=L
    77, // 12=M
    78, // 13=N
    79, // 14=O
    80, // 15=P
    81, // 16=Q
    82, // 17=R
    83, // 18=S
    84, // 19=T
    85, // 20=U
    86, // 21=V
    87, // 22=W
    88, // 23=X
    89, // 24=Y
    90, // 25=Z
    97, // 26=a
    98, // 27=b
    99, // 28=c
    100, // 29=d
    101, // 30=e
    102, // 31=f
    103, // 32=g
    104, // 33=h
    105, // 34=i
    106, // 35=j
    107, // 36=k
    108, // 37=l
    109, // 38=m
    110, // 39=n
    111, // 40=o
    112, // 41=p
    113, // 42=q
    114, // 43=r
    115, // 44=s
    116, // 45=t
    117, // 46=u
    118, // 47=v
    119, // 48=w
    120, // 49=x
    121, // 50=y
    122, // 51=z
    48, // 52=0
    49, // 53=1
    50, // 54=2
    51, // 55=3
    52, // 56=4
    53, // 57=5
    54, // 58=6
    55, // 59=7
    56, // 60=8
    57, // 61=9
    45, // 62=-
    95, // 63=_
    // PADDING FOLLOWS, not used during lookups
    61, // 64==
  ]
}
