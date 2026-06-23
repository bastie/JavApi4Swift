// SPDX-FileCopyrightText: 2025 - Sebastian Ritter <bastie@users.noreply.github.com>
// SPDX-License-Identifier: MIT

#if os(WASI)

extension java.net.HttpURLConnection {
  /// WASM-compatible replacement for `HTTPURLResponse.localizedString(forStatusCode:)`.
  ///
  /// Foundation's `HTTPURLResponse` is unavailable on WASI. This extension provides
  /// the same functionality using a static lookup table of all standardised HTTP
  /// status code reason phrases as defined by IANA.
  internal func httpStatusCodeDescription(forStatusCode code: Int) -> String? {
    return Self._httpStatusCodeTable[code]
  }
  
  // IANA HTTP Status Code Registry — https://www.iana.org/assignments/http-status-codes
  private static let _httpStatusCodeTable: [Int: String] = [
    // 1xx Informational
    100: "Continue",
    101: "Switching Protocols",
    102: "Processing",
    103: "Early Hints",
    
    // 2xx Successful
    200: "OK",
    201: "Created",
    202: "Accepted",
    203: "Non-Authoritative Information",
    204: "No Content",
    205: "Reset Content",
    206: "Partial Content",
    207: "Multi-Status",
    208: "Already Reported",
    226: "IM Used",
    
    // 3xx Redirection
    300: "Multiple Choices",
    301: "Moved Permanently",
    302: "Found",
    303: "See Other",
    304: "Not Modified",
    305: "Use Proxy",
    307: "Temporary Redirect",
    308: "Permanent Redirect",
    
    // 4xx Client Error
    400: "Bad Request",
    401: "Unauthorized",
    402: "Payment Required",
    403: "Forbidden",
    404: "Not Found",
    405: "Method Not Allowed",
    406: "Not Acceptable",
    407: "Proxy Authentication Required",
    408: "Request Timeout",
    409: "Conflict",
    410: "Gone",
    411: "Length Required",
    412: "Precondition Failed",
    413: "Content Too Large",
    414: "URI Too Long",
    415: "Unsupported Media Type",
    416: "Range Not Satisfiable",
    417: "Expectation Failed",
    421: "Misdirected Request",
    422: "Unprocessable Content",
    423: "Locked",
    424: "Failed Dependency",
    425: "Too Early",
    426: "Upgrade Required",
    428: "Precondition Required",
    429: "Too Many Requests",
    431: "Request Header Fields Too Large",
    451: "Unavailable For Legal Reasons",
    
    // 5xx Server Error
    500: "Internal Server Error",
    501: "Not Implemented",
    502: "Bad Gateway",
    503: "Service Unavailable",
    504: "Gateway Timeout",
    505: "HTTP Version Not Supported",
    506: "Variant Also Negotiates",
    507: "Insufficient Storage",
    508: "Loop Detected",
    510: "Not Extended",
    511: "Network Authentication Required",
  ]
}
#endif
