/**
 * Tae Won Ha - http://taewon.de - @hataewon
 * See LICENSE
 */

import Cocoa
import XCTest
import Nimble

@testable import NvimView

class TypesetterWithoutLigaturesTest: XCTestCase {

  func testSimpleAsciiChars() {
    let runs = typesetter.runsWithoutLigatures(
      nvimCells: emojiMarked(["a", "b", "c"]),
      startColumn: 10,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(3))
    expect(run.positions).to(equal(
      (10..<13).map { CGPoint(x: CGFloat($0) * defaultWidth, y: yPosition) }
    ))

    self.assertEmojiMarker(run: runs[1], xPosition: 13 * defaultWidth)
  }

  func testAccentedChars() {
    let runs = typesetter.runsWithoutLigatures(
      nvimCells: emojiMarked(["ü", "î", "ñ"]),
      startColumn: 20,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(3))
    expect(run.positions).to(equal(
      (20..<23).map { CGPoint(x: CGFloat($0) * defaultWidth, y: yPosition) }
    ))

    self.assertEmojiMarker(run: runs[1], xPosition: 23 * defaultWidth)
  }

  func testCombiningChars() {
    let runs = typesetter.runsWithoutLigatures(
      nvimCells: emojiMarked(
        ["a", "a\u{1DC1}", "a\u{032A}", "a\u{034B}", "b", "c"]
      ),
      startColumn: 10,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(6))

    var glyphRun = runs[0]
    expect(glyphRun.font).to(equal(defaultFont))
    expect(glyphRun.glyphs).to(haveCount(1))
    expect(glyphRun.positions).to(equal(
      [
        CGPoint(x: 10 * defaultWidth, y: yPosition)
      ]
    ))

    var run = runs[1]
    expect(run.font).to(equal(courierNew))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions[0])
      .to(equal(CGPoint(x: 11 * defaultWidth, y: yPosition)))
    expect(run.positions[1].x)
      .to(beCloseTo(11 * defaultWidth + 0.003, within: 0.001))
    expect(run.positions[1].y).to(equal(yPosition))

    run = runs[2]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions[0])
      .to(equal(CGPoint(x: 12 * defaultWidth, y: yPosition)))
    expect(run.positions[1].x)
      .to(beCloseTo(12 * defaultWidth, within: 0.001))
    expect(run.positions[1].y).to(equal(yPosition))

    run = runs[3]
    expect(run.font).to(equal(monaco))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions[0])
      .to(equal(CGPoint(x: 13 * defaultWidth, y: yPosition)))
    expect(run.positions[1].x)
      .to(beCloseTo(13 * defaultWidth + 7.804, within: 0.001))
    expect(run.positions[1].y).to(equal(yPosition))

    run = runs[4]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 14 * defaultWidth, y: yPosition),
        CGPoint(x: 15 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertEmojiMarker(run: runs[5], xPosition: 16 * defaultWidth)
  }

  func testSimpleEmojis() {
    let runs = typesetter.runsWithoutLigatures(
      nvimCells: asciiMarked(["a", "b", "\u{1F600}", "", "\u{1F377}", ""]),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(3))

    var run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 1 * defaultWidth, y: yPosition),
        CGPoint(x: 2 * defaultWidth, y: yPosition),
      ]
    ))

    run = runs[1]
    expect(run.font).to(equal(emoji))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 3 * defaultWidth, y: yPosition),
        CGPoint(x: 5 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertAsciiMarker(run: runs[2], xPosition: 7 * defaultWidth)
  }

  func testEmojisWithFitzpatrickModifier() {
    let runs = typesetter.runsWithoutLigatures(
      nvimCells: asciiMarked(["a", "\u{1F476}", "", "\u{1F3FD}", ""]),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    expect(runs).to(haveCount(3))

    var run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(1))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 1 * defaultWidth, y: yPosition),
      ]
    ))

    run = runs[1]
    expect(run.font).to(equal(emoji))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 2 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertAsciiMarker(run: runs[2], xPosition: 6 * defaultWidth)
  }

  func testHangul() {
    let runs = typesetter.runsWithoutLigatures(
      nvimCells: asciiMarked(["a", "b", "하", "", "태", "", "원", ""]),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(3))

    var run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 1 * defaultWidth, y: yPosition),
        CGPoint(x: 2 * defaultWidth, y: yPosition),
      ]
    ))

    run = runs[1]
    expect(run.font).to(equal(gothic))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 3 * defaultWidth, y: yPosition),
        CGPoint(x: 5 * defaultWidth, y: yPosition),
        CGPoint(x: 7 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertAsciiMarker(run: runs[2], xPosition: 9 * defaultWidth)
  }

  func testHanja() {
    let runs = typesetter.runsWithoutLigatures(
      nvimCells: asciiMarked(["a", "b", "河", "", "泰", "", "元", ""]),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(3))

    var run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 1 * defaultWidth, y: yPosition),
        CGPoint(x: 2 * defaultWidth, y: yPosition),
      ]
    ))

    run = runs[1]
    expect(run.font).to(equal(gothic))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 3 * defaultWidth, y: yPosition),
        CGPoint(x: 5 * defaultWidth, y: yPosition),
        CGPoint(x: 7 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertAsciiMarker(run: runs[2], xPosition: 9 * defaultWidth)
  }

  func testOthers() {
    let runs = typesetter.runsWithoutLigatures(
      nvimCells: emojiMarked(["a", "\u{10437}", "\u{1F14}"]),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(4))

    var run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(1))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 1 * defaultWidth, y: yPosition)
      ]
    ))

    run = runs[1]
    expect(run.font).to(equal(baskerville))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 2 * defaultWidth, y: yPosition),
      ]
    ))

    run = runs[2]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(1))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 3 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertEmojiMarker(run: runs[3], xPosition: 4 * defaultWidth)
  }

  func testSimpleLigatureChars() {
    let runs = typesetter.runsWithoutLigatures(
      nvimCells: emojiMarked(["a", "-", "-", ">", "a"]),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: fira,
      cellWidth: firaWidth
    )

    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(fira))
    expect(run.glyphs).to(equal([133, 1023, 1023, 1148, 133]))
    expect(run.positions).to(equal(
      (1..<6).map { CGPoint(x: CGFloat($0) * firaWidth, y: yPosition) }
    ))

    self.assertEmojiMarker(run: runs[1], xPosition: 6 * firaWidth)
  }

  private func assertAsciiMarker(run: FontGlyphRun, xPosition: CGFloat) {
    expect(run.font).to(equal(defaultFont))
    expect(run.positions).to(equal([CGPoint(x: xPosition, y: yPosition)]))
  }

  private func assertEmojiMarker(run: FontGlyphRun, xPosition: CGFloat) {
    expect(run.font).to(equal(emoji))
    expect(run.positions).to(equal([CGPoint(x: xPosition, y: yPosition)]))
  }
}

class NewTypesetterWithLigaturesTest: XCTestCase {

  func testGroupGlyphsAndUtf16Cells() {
    let cells = typesetter.groupUtf16CellsAndGlyphs(
      positionedCells: [
        PositionedUtf16Cell(utf16: [0, 1, 2], column: 1),
        PositionedUtf16Cell(utf16: [3, 4], column: 3),
        PositionedUtf16Cell(utf16: [5, 6], column: 5),
        PositionedUtf16Cell(utf16: [7], column: 6),
      ],
      cellIndexedUtf16Chars: [
        CellIndexedUtf16Char(codeUnit: 0, index: 0),
        CellIndexedUtf16Char(codeUnit: 1, index: 0),
        CellIndexedUtf16Char(codeUnit: 2, index: 0),
        CellIndexedUtf16Char(codeUnit: 3, index: 1),
        CellIndexedUtf16Char(codeUnit: 4, index: 1),
        CellIndexedUtf16Char(codeUnit: 5, index: 2),
        CellIndexedUtf16Char(codeUnit: 6, index: 2),
        CellIndexedUtf16Char(codeUnit: 7, index: 3),
      ],
      utf16IndexedGlyphs: [
        Utf16IndexedGlyph(
          glyph: 0, index: 0, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 1, index: 1, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 2, index: 2, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 3, index: 3, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 4, index: 7, position: .zero, advance: .zero
        ),
      ])
    expect(cells).to(haveCount(3))

    var cell = cells[0]
    var utf16Cells = cell.0
    var glyphs = cell.1
    expect(utf16Cells).to(haveCount(1))
    expect(utf16Cells[0].utf16).to(equal([0, 1, 2]))
    expect(utf16Cells[0].column).to(equal(1))
    expect(glyphs).to(haveCount(3))
    expect(glyphs[0].glyph).to(equal(0))
    expect(glyphs[1].glyph).to(equal(1))
    expect(glyphs[2].glyph).to(equal(2))

    cell = cells[1]
    utf16Cells = cell.0
    glyphs = cell.1
    expect(utf16Cells).to(haveCount(2))
    expect(utf16Cells[0].utf16).to(equal([3, 4]))
    expect(utf16Cells[0].column).to(equal(3))
    expect(utf16Cells[1].utf16).to(equal([5, 6]))
    expect(utf16Cells[1].column).to(equal(5))
    expect(glyphs).to(haveCount(1))
    expect(glyphs[0].glyph).to(equal(3))

    cell = cells[2]
    utf16Cells = cell.0
    glyphs = cell.1
    expect(utf16Cells).to(haveCount(1))
    expect(utf16Cells[0].utf16).to(equal([7]))
    expect(utf16Cells[0].column).to(equal(6))
    expect(glyphs).to(haveCount(1))
    expect(glyphs[0].glyph).to(equal(4))
  }

  func testGroupGlyphsAndUtf16Cells2() {
    let cells = typesetter.groupUtf16CellsAndGlyphs(
      positionedCells: [
        PositionedUtf16Cell(utf16: [0, 1, 2], column: 1),
        PositionedUtf16Cell(utf16: [3, 4], column: 3),
        PositionedUtf16Cell(utf16: [5, 6], column: 5),
        PositionedUtf16Cell(utf16: [7], column: 6),
        PositionedUtf16Cell(utf16: [8], column: 7),
        PositionedUtf16Cell(utf16: [9], column: 8),
      ],
      cellIndexedUtf16Chars: [
        CellIndexedUtf16Char(codeUnit: 0, index: 0),
        CellIndexedUtf16Char(codeUnit: 1, index: 0),
        CellIndexedUtf16Char(codeUnit: 2, index: 0),
        CellIndexedUtf16Char(codeUnit: 3, index: 1),
        CellIndexedUtf16Char(codeUnit: 4, index: 1),
        CellIndexedUtf16Char(codeUnit: 5, index: 2),
        CellIndexedUtf16Char(codeUnit: 6, index: 2),
        CellIndexedUtf16Char(codeUnit: 7, index: 3),
        CellIndexedUtf16Char(codeUnit: 8, index: 4),
        CellIndexedUtf16Char(codeUnit: 9, index: 5),
      ],
      utf16IndexedGlyphs: [
        Utf16IndexedGlyph(
          glyph: 0, index: 0, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 1, index: 2, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 2, index: 3, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 3, index: 7, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 4, index: 8, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 5, index: 8, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 6, index: 8, position: .zero, advance: .zero
        ),
        Utf16IndexedGlyph(
          glyph: 7, index: 9, position: .zero, advance: .zero
        ),
      ])
    expect(cells).to(haveCount(5))

    var cell = cells[0]
    var utf16Cells = cell.0
    var glyphs = cell.1
    expect(utf16Cells).to(haveCount(1))
    expect(utf16Cells[0].utf16).to(equal([0, 1, 2]))
    expect(utf16Cells[0].column).to(equal(1))
    expect(glyphs).to(haveCount(2))
    expect(glyphs[0].glyph).to(equal(0))
    expect(glyphs[1].glyph).to(equal(1))

    cell = cells[1]
    utf16Cells = cell.0
    glyphs = cell.1
    expect(utf16Cells).to(haveCount(2))
    expect(utf16Cells[0].utf16).to(equal([3, 4]))
    expect(utf16Cells[0].column).to(equal(3))
    expect(utf16Cells[1].utf16).to(equal([5, 6]))
    expect(utf16Cells[1].column).to(equal(5))
    expect(glyphs).to(haveCount(1))
    expect(glyphs[0].glyph).to(equal(2))

    cell = cells[2]
    utf16Cells = cell.0
    glyphs = cell.1
    expect(utf16Cells).to(haveCount(1))
    expect(utf16Cells[0].utf16).to(equal([7]))
    expect(utf16Cells[0].column).to(equal(6))
    expect(glyphs).to(haveCount(1))
    expect(glyphs[0].glyph).to(equal(3))

    cell = cells[3]
    utf16Cells = cell.0
    glyphs = cell.1
    expect(utf16Cells).to(haveCount(1))
    expect(utf16Cells[0].utf16).to(equal([8]))
    expect(utf16Cells[0].column).to(equal(7))
    expect(glyphs).to(haveCount(3))
    expect(glyphs[0].glyph).to(equal(4))
    expect(glyphs[1].glyph).to(equal(5))
    expect(glyphs[2].glyph).to(equal(6))

    cell = cells[4]
    utf16Cells = cell.0
    glyphs = cell.1
    expect(utf16Cells).to(haveCount(1))
    expect(utf16Cells[0].utf16).to(equal([9]))
    expect(utf16Cells[0].column).to(equal(8))
    expect(glyphs).to(haveCount(1))
    expect(glyphs[0].glyph).to(equal(7))
  }

  func testGroupByStringRanges() {
    let groups = typesetter.groupByStringRanges(
      stringRanges: [
        0..<5,
        5..<9,
      ],
      groupedCellsAndGlyphs: [
        (
          [
            PositionedUtf16Cell(utf16: [0, 1, 2], column: 1),
            PositionedUtf16Cell(utf16: [3, 4], column: 2)
          ],
          [
            Utf16IndexedGlyph(
              glyph: 0, index: 0, position: .zero, advance: .zero
            ),
            Utf16IndexedGlyph(
              glyph: 1, index: 3, position: .zero, advance: .zero
            ),
          ]
        ),
        (
          [
            PositionedUtf16Cell(utf16: [5], column: 3),
            PositionedUtf16Cell(utf16: [6], column: 4),
          ],
          [
            Utf16IndexedGlyph(
              glyph: 2, index: 5, position: .zero, advance: .zero
            ),
            Utf16IndexedGlyph(
              glyph: 3, index: 6, position: .zero, advance: .zero
            ),
          ]
        ),
        (
          [
            PositionedUtf16Cell(utf16: [7], column: 5),
            PositionedUtf16Cell(utf16: [8], column: 6),
          ],
          [
            Utf16IndexedGlyph(
              glyph: 4, index: 7, position: .zero, advance: .zero
            ),
            Utf16IndexedGlyph(
              glyph: 5, index: 8, position: .zero, advance: .zero
            ),
          ]
        ),
      ])
    expect(groups).to(haveCount(2))
    expect(groups[0]).to(equal(0...0))
    expect(groups[1]).to(equal(1...2))
  }

  func testGroupByStringRanges2() {
    let groups = typesetter.groupByStringRanges(
      stringRanges: [
        0..<5,
        5..<7,
        7..<8,
      ],
      groupedCellsAndGlyphs: [
        (
          [
            PositionedUtf16Cell(utf16: [0], column: 1),
          ],
          [
            Utf16IndexedGlyph(
              glyph: 0, index: 0, position: .zero, advance: .zero
            ),
            Utf16IndexedGlyph(
              glyph: 1, index: 0, position: .zero, advance: .zero
            ),
          ]
        ),
        (
          [
            PositionedUtf16Cell(utf16: [1], column: 2),
            PositionedUtf16Cell(utf16: [2], column: 3),
            PositionedUtf16Cell(utf16: [3], column: 4),
            PositionedUtf16Cell(utf16: [4], column: 5),
          ],
          [
            Utf16IndexedGlyph(
              glyph: 2, index: 1, position: .zero, advance: .zero
            ),
            Utf16IndexedGlyph(
              glyph: 3, index: 3, position: .zero, advance: .zero
            ),
          ]
        ),
        (
          [
            PositionedUtf16Cell(utf16: [5], column: 6),
            PositionedUtf16Cell(utf16: [6], column: 7),
          ],
          [
            Utf16IndexedGlyph(
              glyph: 4, index: 5, position: .zero, advance: .zero
            ),
            Utf16IndexedGlyph(
              glyph: 5, index: 6, position: .zero, advance: .zero
            ),
          ]
        ),
        (
          [
            PositionedUtf16Cell(utf16: [7], column: 6),
          ],
          [
            Utf16IndexedGlyph(
              glyph: 6, index: 7, position: .zero, advance: .zero
            ),
          ]
        ),
      ])
    expect(groups).to(haveCount(3))
    expect(groups[0]).to(equal(0...1))
    expect(groups[1]).to(equal(2...2))
    expect(groups[2]).to(equal(3...3))
  }

  func testSimpleAsciiChars() {
    let runs = typesetter.fontGlyphRunsWithLigatures(
      nvimUtf16Cells: utf16Chars(emojiMarked(["a", "b", "c"])),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(3))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 1 * defaultWidth, y: yPosition),
        CGPoint(x: 2 * defaultWidth, y: yPosition),
        CGPoint(x: 3 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertEmojiMarker(run: runs[1], xPosition: 4 * defaultWidth)
  }

  func testAccentedChars() {
    let runs = typesetter.fontGlyphRunsWithLigatures(
      nvimUtf16Cells: utf16Chars(emojiMarked(["ü", "î", "ñ"])),
      startColumn: 10,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(3))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 10 * defaultWidth, y: yPosition),
        CGPoint(x: 11 * defaultWidth, y: yPosition),
        CGPoint(x: 12 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertEmojiMarker(run: runs[1], xPosition: 13 * defaultWidth)
  }

  func testCombiningChars() {
    let runs = typesetter.fontGlyphRunsWithLigatures(
      nvimUtf16Cells: utf16Chars(
        emojiMarked(["a\u{1DC1}", "a\u{032A}", "a\u{034B}"])
      ),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(4))

    // The positions of the combining characters are copied from print outputs
    // and they are visually checked by drawing them and inspecting them...
    var run = runs[0]
    expect(run.font).to(equal(courierNew))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions[0])
      .to(equal(CGPoint(x: 1 * defaultWidth, y: yPosition)))
    expect(run.positions[1].x)
      .to(beCloseTo(1 * defaultWidth + 0.003, within: 0.001))
    expect(run.positions[1].y).to(equal(yPosition))

    run = runs[1]
    expect(run.font).to(equal(defaultFont))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions[0])
      .to(equal(CGPoint(x: 2 * defaultWidth, y: yPosition)))
    expect(run.positions[1].x)
      .to(beCloseTo(2 * defaultWidth, within: 0.001))
    expect(run.positions[1].y).to(equal(yPosition))

    run = runs[2]
    expect(run.font).to(equal(monaco))
    expect(run.glyphs).to(haveCount(2))
    expect(run.positions[0])
      .to(equal(CGPoint(x: 3 * defaultWidth, y: yPosition)))
    expect(run.positions[1].x)
      .to(beCloseTo(3 * defaultWidth + 7.804, within: 0.001))
    expect(run.positions[1].y).to(equal(yPosition))

    self.assertEmojiMarker(run: runs[3], xPosition: 4 * defaultWidth)
  }

  func testSimpleEmojis() {
    let runs = typesetter.fontGlyphRunsWithLigatures(
      nvimUtf16Cells: utf16Chars(
        asciiMarked(["\u{1F600}", "", "\u{1F377}", ""])
      ),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(emoji))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 0, y: yPosition),
        CGPoint(x: 2 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertAsciiMarker(run: runs[1], xPosition: 4 * defaultWidth)
  }

  func testEmojisWithFitzpatrickModifier() {
    let runs = typesetter.fontGlyphRunsWithLigatures(
      // Neovim does not yet seem to support the Fitzpatrick modifiers:
      // It sends the following instead of ["\u{1F476}\u{1F3FD}", ""].
      // We render it together anyway and treat it as a 4-cell character.
      nvimUtf16Cells: utf16Chars(
        asciiMarked(["\u{1F476}", "", "\u{1F3FD}", ""])
      ),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(emoji))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 0, y: yPosition),
      ]
    ))

    self.assertAsciiMarker(run: runs[1], xPosition: 4 * defaultWidth)
  }

  func testEmojisWithZeroWidthJoiner() {
    // Neovim does not yet seem to support Emojis composed by zero-width-joiner:
    // If it did, we'd render it correctly.
    let runs = typesetter.fontGlyphRunsWithLigatures(
      nvimUtf16Cells: utf16Chars(asciiMarked(
        [
          "\u{1F468}\u{200D}\u{1F468}\u{200D}\u{1F467}\u{200D}\u{1F467}", "",
        ]
      )),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(emoji))
    expect(run.glyphs).to(haveCount(1))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 1 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertAsciiMarker(run: runs[1], xPosition: 3 * defaultWidth)
  }

  func testHangul() {
    let runs = typesetter.fontGlyphRunsWithLigatures(
      nvimUtf16Cells: utf16Chars(
        asciiMarked(["하", "", "태", "", "원", ""])
      ),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(gothic))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 1 * defaultWidth, y: yPosition),
        CGPoint(x: 3 * defaultWidth, y: yPosition),
        CGPoint(x: 5 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertAsciiMarker(run: runs[1], xPosition: 7 * defaultWidth)
  }

  func testHanja() {
    let runs = typesetter.fontGlyphRunsWithLigatures(
      nvimUtf16Cells: utf16Chars(
        asciiMarked(["河", "", "泰", "", "元", ""])
      ),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(gothic))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 1 * defaultWidth, y: yPosition),
        CGPoint(x: 3 * defaultWidth, y: yPosition),
        CGPoint(x: 5 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertAsciiMarker(run: runs[1], xPosition: 7 * defaultWidth)
  }

  func testOthers() {
    let runs = typesetter.fontGlyphRunsWithLigatures(
      nvimUtf16Cells: utf16Chars(
        emojiMarked(["\u{10437}", "\u{1F14}"])
      ),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )
    expect(runs).to(haveCount(3))

    var run = runs[0]
    expect(run.font).to(equal(baskerville))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 0, y: yPosition),
      ]
    ))

    run = runs[1]
    expect(run.font).to(equal(defaultFont))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 1 * defaultWidth, y: yPosition),
      ]
    ))

    self.assertEmojiMarker(run: runs[2], xPosition: 2 * defaultWidth)
  }

  func testSimpleLigatureChars() {
    let runs = typesetter.fontGlyphRunsWithLigatures(
      nvimUtf16Cells: utf16Chars(
        emojiMarked(["-", "-", ">", "a"])
      ),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: fira,
      cellWidth: firaWidth
    )
    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(fira))
    // Ligatures of popular monospace fonts like Fira Code seem to be composed
    // of multiple characters with the same advance as other normal characters.
    expect(run.glyphs).to(equal([1614, 1614, 1063, 133]))
    expect(run.positions).to(equal(
      [
        CGPoint(x: 0, y: yPosition),
        CGPoint(x: 1 * firaWidth, y: yPosition),
        CGPoint(x: 2 * firaWidth, y: yPosition),
        CGPoint(x: 3 * firaWidth, y: yPosition),
      ]
    ))

    self.assertEmojiMarker(run: runs[1], xPosition: 4 * firaWidth)
  }

  private func assertAsciiMarker(run: FontGlyphRun, xPosition: CGFloat) {
    expect(run.font).to(equal(defaultFont))
    expect(run.positions).to(equal(
      [
        CGPoint(x: xPosition, y: yPosition),
      ]
    ))
  }

  private func assertEmojiMarker(run: FontGlyphRun, xPosition: CGFloat) {
    expect(run.font).to(equal(emoji))
    expect(run.positions).to(equal(
      [
        CGPoint(x: xPosition, y: yPosition),
      ]
    ))
  }
}

class TypesetterWithLigaturesTest: XCTestCase {

  func testSimpleAsciiChars() {
    let drawableRuns = typesetter.runsWithLigatures(
      nvimCells: emojiMarked(["a", "b", "c"]),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    guard let runs = drawableRuns as? [Run.CoreText] else {
      fail(("not core text runs"))
      return
    }

    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.location).to(equal(CGPoint(x: 1 * defaultWidth, y: yPosition)))

    self.assertEmojiMarker(run: runs[1], location: 4 * defaultWidth)
  }

  func testAccentedChars() {
    let drawableRuns = typesetter.runsWithLigatures(
      nvimCells: emojiMarked(["ü", "î", "ñ"]),
      startColumn: 10,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    guard let runs = drawableRuns as? [Run.CoreText] else {
      fail(("not core text runs"))
      return
    }

    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(defaultFont))
    expect(run.location).to(equal(CGPoint(x: 10 * defaultWidth, y: yPosition)))

    self.assertEmojiMarker(run: runs[1], location: 13 * defaultWidth)
  }

  func testCombiningChars() {
    let drawableRuns = typesetter.runsWithLigatures(
      nvimCells: emojiMarked(["a\u{1DC1}", "a\u{032A}", "a\u{034B}"]),
      startColumn: 1,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    guard let runs = drawableRuns as? [Run.CoreText] else {
      fail(("not core text runs"))
      return
    }

    expect(runs).to(haveCount(4))

    var run: Run.CoreText

    run = runs[0]
    expect(run.font).to(equal(courierNew))
    expect(run.location).to(equal(CGPoint(x: 1 * defaultWidth, y: yPosition)))

    run = runs[1]
    expect(run.font).to(equal(defaultFont))
    expect(run.location).to(equal(CGPoint(x: 2 * defaultWidth, y: yPosition)))

    run = runs[2]
    expect(run.font).to(equal(monaco))
    expect(run.location).to(equal(CGPoint(x: 3 * defaultWidth, y: yPosition)))

    self.assertEmojiMarker(run: runs[3], location: 4 * defaultWidth)
  }

  func testSimpleEmojis() {
    let drawableRuns = typesetter.runsWithLigatures(
      nvimCells: asciiMarked(["\u{1F600}", "", "\u{1F377}", ""]),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    guard let runs = drawableRuns as? [Run.CoreText] else {
      fail(("not core text runs"))
      return
    }

    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(emoji))
    expect(run.location).to(equal(CGPoint(x: 0, y: yPosition)))

    self.assertAsciiMarker(run: runs[1], location: 4 * defaultWidth)
  }

  func testEmojisWithFitzpatrickModifier() {
    let drawableRuns = typesetter.runsWithLigatures(
      nvimCells: asciiMarked(["\u{1F476}", "", "\u{1F3FD}", ""]),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    guard let runs = drawableRuns as? [Run.CoreText] else {
      fail(("not core text runs"))
      return
    }

    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(emoji))
    expect(run.location).to(equal(CGPoint(x: 0, y: yPosition)))

    self.assertAsciiMarker(run: runs[1], location: 4 * defaultWidth)
  }

  func testEmojisWithZeroWidthJoiner() {
    let drawableRuns = typesetter.runsWithLigatures(
      nvimCells: asciiMarked(
        [
          "\u{1F468}\u{200D}\u{1F468}\u{200D}\u{1F467}\u{200D}\u{1F467}", "",
          "\u{1F3FD}", ""
        ]
      ),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    guard let runs = drawableRuns as? [Run.CoreText] else {
      fail(("not core text runs"))
      return
    }

    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(emoji))
    expect(run.location).to(equal(CGPoint(x: 0, y: yPosition)))

    self.assertAsciiMarker(run: runs[1], location: 4 * defaultWidth)
  }

  func testHangul() {
    let drawableRuns = typesetter.runsWithLigatures(
      nvimCells: asciiMarked(["하", "", "태", "", "원", ""]),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    guard let runs = drawableRuns as? [Run.CoreText] else {
      fail(("not core text runs"))
      return
    }

    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(gothic))
    expect(run.location).to(equal(CGPoint(x: 0, y: yPosition)))

    self.assertAsciiMarker(run: runs[1], location: 6 * defaultWidth)
  }

  func testHanja() {
    let drawableRuns = typesetter.runsWithLigatures(
      nvimCells: asciiMarked(["河", "", "泰", "", "元", ""]),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    guard let runs = drawableRuns as? [Run.CoreText] else {
      fail(("not core text runs"))
      return
    }

    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(gothic))
    expect(run.location).to(equal(CGPoint(x: 0, y: yPosition)))

    self.assertAsciiMarker(run: runs[1], location: 6 * defaultWidth)
  }

  func testOthers() {
    let drawableRuns = typesetter.runsWithLigatures(
      nvimCells: emojiMarked(["\u{10437}", "\u{1F14}"]),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: defaultFont,
      cellWidth: defaultWidth
    )

    guard let runs = drawableRuns as? [Run.CoreText] else {
      fail(("not core text runs"))
      return
    }

    expect(runs).to(haveCount(3))

    var run = runs[0]
    expect(run.font).to(equal(baskerville))
    expect(run.location).to(equal(CGPoint(x: 0, y: yPosition)))

    run = runs[1]
    expect(run.font).to(equal(defaultFont))
    expect(run.location).to(equal(CGPoint(x: 1 * defaultWidth, y: yPosition)))

    self.assertEmojiMarker(run: runs[2], location: 2 * defaultWidth)
  }

  func testSimpleLigatureChars() {
    let drawableRuns = typesetter.runsWithLigatures(
      nvimCells: emojiMarked([">", "=", " ", "a"]),
      startColumn: 0,
      yPosition: yPosition,
      foreground: 0,
      font: fira,
      cellWidth: firaWidth
    )

    guard let runs = drawableRuns as? [Run.CoreText] else {
      fail(("not core text runs"))
      return
    }

    expect(runs).to(haveCount(2))

    let run = runs[0]
    expect(run.font).to(equal(fira))
    expect(run.location).to(equal(CGPoint(x: 0, y: yPosition)))

    self.assertEmojiMarker(run: runs[1], location: 4 * firaWidth)
  }

  private func assertAsciiMarker(
    run: CustomFontDrawableRun, location: CGFloat
  ) {
    expect(run.font).to(equal(defaultFont))
    expect(run.location).to(equal(CGPoint(x: location, y: yPosition)))
  }

  private func assertEmojiMarker(
    run: CustomFontDrawableRun, location: CGFloat
  ) {
    expect(run.font).to(equal(emoji))
    expect(run.location).to(equal(CGPoint(x: location, y: yPosition)))
  }
}

private let defaultFont = NSFont(name: "Menlo", size: 13)!
private let fira = NSFont(name: "FiraCode-Regular", size: 13)!
private let courierNew = NSFont(name: "Courier New", size: 13)!
private let monaco = NSFont(name: "Monaco", size: 13)!
private let emoji = NSFont(name: "AppleColorEmoji", size: 13)!
private let gothic = NSFont(name: "Apple SD Gothic Neo", size: 13)!
private let baskerville = NSFont(name: "Baskerville", size: 13)!

private let defaultWidth = FontUtils
  .cellSize(of: defaultFont, linespacing: 1).width
private let firaWidth = FontUtils.cellSize(of: fira, linespacing: 1).width

private let yPosition = CGFloat(8)

private let typesetter = Typesetter()

private func asciiMarked(_ strings: [String]) -> [String] {
  return strings + ["a"]
}

private func emojiMarked(_ strings: [String]) -> [String] {
  return strings + ["\u{1F600}"]
}

private func utf16Chars(_ array: [String]) -> [[Unicode.UTF16.CodeUnit]] {
  return array.map { Array($0.utf16) }
}
