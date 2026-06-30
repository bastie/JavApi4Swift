/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

import Testing
@testable import JavApi

// =============================================================================
// MARK: - Paper
// =============================================================================

@Suite("java.awt.print.Paper")
struct JavApi_awt_print_Paper_Tests {

  @Test("Default size is US Letter (612 × 792 pt)")
  func defaultSize() {
    let paper = java.awt.print.Paper()
    #expect(paper.getWidth()  == 612.0)
    #expect(paper.getHeight() == 792.0)
  }

  @Test("Default imageable area has 1-inch (72 pt) margins")
  func defaultImageableArea() {
    let paper = java.awt.print.Paper()
    #expect(paper.getImageableX()      == 72.0)
    #expect(paper.getImageableY()      == 72.0)
    #expect(paper.getImageableWidth()  == 612.0 - 2 * 72.0)
    #expect(paper.getImageableHeight() == 792.0 - 2 * 72.0)
  }

  @Test("setSize changes dimensions")
  func setSize() {
    let paper = java.awt.print.Paper()
    paper.setSize(595.0, 842.0)   // A4
    #expect(paper.getWidth()  == 595.0)
    #expect(paper.getHeight() == 842.0)
  }

  @Test("setImageableArea round-trips correctly")
  func setImageableArea() {
    let paper = java.awt.print.Paper()
    paper.setImageableArea(10, 20, 400, 600)
    #expect(paper.getImageableX()      == 10.0)
    #expect(paper.getImageableY()      == 20.0)
    #expect(paper.getImageableWidth()  == 400.0)
    #expect(paper.getImageableHeight() == 600.0)
  }

  @Test("clone produces independent copy")
  func clone() {
    let original = java.awt.print.Paper()
    let copy = original.clone()
    copy.setSize(100, 200)
    #expect(original.getWidth()  == 612.0)   // original unchanged
    #expect(original.getHeight() == 792.0)
    #expect(copy.getWidth()      == 100.0)
  }
}

// =============================================================================
// MARK: - PageFormat
// =============================================================================

@Suite("java.awt.print.PageFormat")
struct JavApi_awt_print_PageFormat_Tests {

  @Test("Default orientation is PORTRAIT")
  func defaultOrientation() {
    let pf = java.awt.print.PageFormat()
    #expect(pf.getOrientation() == java.awt.print.PageFormat.PORTRAIT)
  }

  @Test("PORTRAIT width/height match Paper width/height")
  func portraitDimensions() {
    let pf = java.awt.print.PageFormat()
    #expect(pf.getWidth()  == 612.0)
    #expect(pf.getHeight() == 792.0)
  }

  @Test("LANDSCAPE swaps width and height")
  func landscapeDimensions() {
    let pf = java.awt.print.PageFormat()
    pf.setOrientation(java.awt.print.PageFormat.LANDSCAPE)
    #expect(pf.getWidth()  == 792.0)
    #expect(pf.getHeight() == 612.0)
  }

  @Test("LANDSCAPE imageable width equals portrait imageable height")
  func landscapeImageableDimensions() {
    let pf = java.awt.print.PageFormat()
    let portraitImageableH = pf.getImageableHeight()
    pf.setOrientation(java.awt.print.PageFormat.LANDSCAPE)
    #expect(pf.getImageableWidth() == portraitImageableH)
  }

  @Test("setPaper / getPaper round-trip (clone)")
  func setPaper() {
    let pf    = java.awt.print.PageFormat()
    let paper = java.awt.print.Paper()
    paper.setSize(595, 842)
    pf.setPaper(paper)
    #expect(pf.getWidth()  == 595.0)
    #expect(pf.getHeight() == 842.0)
    // Modifying the original paper must not affect the PageFormat (defensive copy)
    paper.setSize(100, 100)
    #expect(pf.getWidth()  == 595.0)
  }

  @Test("clone produces independent copy")
  func clone() {
    let pf   = java.awt.print.PageFormat()
    let copy = pf.clone()
    copy.setOrientation(java.awt.print.PageFormat.LANDSCAPE)
    #expect(pf.getOrientation() == java.awt.print.PageFormat.PORTRAIT)
  }

  @Test("Orientation constants have expected values")
  func orientationConstants() {
    #expect(java.awt.print.PageFormat.PORTRAIT          == 0)
    #expect(java.awt.print.PageFormat.LANDSCAPE         == 1)
    #expect(java.awt.print.PageFormat.REVERSE_LANDSCAPE == 2)
  }
}

// =============================================================================
// MARK: - Printable constants
// =============================================================================

@Suite("java.awt.print.Printable")
struct JavApi_awt_print_Printable_Tests {

  // Helper conformer to access static constants
  private final class StubPrintable: java.awt.print.Printable {
    func print(_ g: java.awt.Graphics,
               _ pf: java.awt.print.PageFormat,
               _ pageIndex: Int) -> Int {
      pageIndex == 0 ? java.awt.print._PrintableNoOp.PAGE_EXISTS : java.awt.print._PrintableNoOp.NO_SUCH_PAGE
    }
  }

  @Test("PAGE_EXISTS == 0, NO_SUCH_PAGE == 1")
  func constants() {
    #expect(java.awt.print._PrintableNoOp.PAGE_EXISTS   == 0)
    #expect(java.awt.print._PrintableNoOp.NO_SUCH_PAGE  == 1)
  }

  @Test("StubPrintable returns PAGE_EXISTS for page 0")
  func stubPageExists() {
    let stub = StubPrintable()
    let result = stub.print(java.awt.Graphics(),
                            java.awt.print.PageFormat(), 0)
    #expect(result == java.awt.print._PrintableNoOp.PAGE_EXISTS)
  }

  @Test("StubPrintable returns NO_SUCH_PAGE for page 1")
  func stubNoSuchPage() {
    let stub = StubPrintable()
    let result = stub.print(java.awt.Graphics(),
                            java.awt.print.PageFormat(), 1)
    #expect(result == java.awt.print._PrintableNoOp.NO_SUCH_PAGE)
  }
}

// =============================================================================
// MARK: - Book
// =============================================================================

@Suite("java.awt.print.Book")
struct JavApi_awt_print_Book_Tests {

  private final class StubPrintable: java.awt.print.Printable {
    func print(_ g: java.awt.Graphics,
               _ pf: java.awt.print.PageFormat,
               _ pageIndex: Int) -> Int {
      java.awt.print._PrintableNoOp.PAGE_EXISTS
    }
  }

  @Test("Empty book has 0 pages")
  func emptyBook() {
    let book = java.awt.print.Book()
    #expect(book.getNumberOfPages() == 0)
  }

  @Test("append adds one page")
  func appendOne() {
    let book = java.awt.print.Book()
    book.append(StubPrintable(), java.awt.print.PageFormat())
    #expect(book.getNumberOfPages() == 1)
  }

  @Test("append with count adds N pages")
  func appendCount() {
    let book = java.awt.print.Book()
    book.append(StubPrintable(), java.awt.print.PageFormat(), 5)
    #expect(book.getNumberOfPages() == 5)
  }

  @Test("getPageFormat throws for out-of-bounds index")
  func getPageFormatOutOfBounds() throws {
    let book = java.awt.print.Book()
    #expect(throws: (any Error).self) {
      try book.getPageFormat(0)
    }
  }

  @Test("getPrintable throws for out-of-bounds index")
  func getPrintableOutOfBounds() throws {
    let book = java.awt.print.Book()
    #expect(throws: (any Error).self) {
      try book.getPrintable(0)
    }
  }

  @Test("getPageFormat returns independent clone")
  func pageFormatClone() throws {
    let book = java.awt.print.Book()
    let pf   = java.awt.print.PageFormat()
    book.append(StubPrintable(), pf)

    let retrieved = try book.getPageFormat(0)
    retrieved.setOrientation(java.awt.print.PageFormat.LANDSCAPE)
    // Original entry in book must be unchanged
    let again = try book.getPageFormat(0)
    #expect(again.getOrientation() == java.awt.print.PageFormat.PORTRAIT)
  }

  @Test("setPage replaces entry")
  func setPage() throws {
    let book = java.awt.print.Book()
    let pf1  = java.awt.print.PageFormat()
    let pf2  = java.awt.print.PageFormat()
    pf2.setOrientation(java.awt.print.PageFormat.LANDSCAPE)

    book.append(StubPrintable(), pf1)
    try book.setPage(0, StubPrintable(), pf2)

    let result = try book.getPageFormat(0)
    #expect(result.getOrientation() == java.awt.print.PageFormat.LANDSCAPE)
  }
}

// =============================================================================
// MARK: - PrinterException hierarchy
// =============================================================================

@Suite("java.awt.print.PrinterException")
struct JavApi_awt_print_PrinterException_Tests {

  @Test("PrinterException is a java.lang.Exception")
  func isException() {
    let ex = java.awt.print.PrinterException("test")
    #expect(ex is java.lang.Exception)
  }

  @Test("PrinterAbortException is a PrinterException")
  func abortIsSubclass() {
    let ex = java.awt.print.PrinterAbortException()
    #expect(ex is java.awt.print.PrinterException)
  }

  @Test("PrinterIOException wraps IOException message")
  func ioExceptionMessage() {
    let io = java.io.IOException("disk full")
    let ex = java.awt.print.PrinterIOException(io)
    #expect(ex.getMessage() == "disk full")
    #expect(ex.ioException.getMessage() == "disk full")
  }
}

// =============================================================================
// MARK: - PrinterJob (headless)
// =============================================================================

@Suite("java.awt.print.PrinterJob (headless)")
struct JavApi_awt_print_PrinterJob_Tests {

  @MainActor @Test("getPrinterJob() returns a PrinterJob")
  func factory() {
    let job = java.awt.print.PrinterJob.getPrinterJob()
    #expect(job is java.awt.print.PrinterJob)
  }

  @Test("defaultPage() returns a copy of default PageFormat")
  @MainActor
  func defaultPage() {
    let job = java.awt.print.PrinterJob.getPrinterJob()
    let pf  = job.defaultPage()
    #expect(pf.getWidth()  > 0)
    #expect(pf.getHeight() > 0)
  }

  @Test("validatePage returns a PageFormat")
  @MainActor
  func validatePage() {
    let job = java.awt.print.PrinterJob.getPrinterJob()
    let pf  = job.validatePage(java.awt.print.PageFormat())
    #expect(pf.getOrientation() == java.awt.print.PageFormat.PORTRAIT)
  }

  @Test("Pageable constant UNKNOWN_NUMBER_OF_PAGES == -1")
  func unknownPages() {
    #expect(java.awt.print.UNKNOWN_NUMBER_OF_PAGES == -1)
  }
}
