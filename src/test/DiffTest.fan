//
// Copyright (c) 2011 by Dmitry Savenko, xored software, Inc. 
// Copyright (c) 2005-2009 by Matthias Hertel, http://www.mathertel.de/
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are permitted provided 
// that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice, this list of conditions and 
//   the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and 
//   the following disclaimer in the documentation and/or other materials provided with the distribution.
// * Neither the name of the copyright owners nor the names of its contributors may be used to endorse or 
//   promote products derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

class DiffTest : Test
{
  
  Void testBase() {
    // empty / empty
    verifyEq(Diff.run("", ""), Delta[,])
    
    // empty / non-empty
    verifyEq(Diff.run("", "a"), [Delta(0..<0, 0..<1)])
    
    // non-empty / empty
    verifyEq(Diff.run("a", ""), [Delta(0..<1, 0..<0)])
    
    // same sequence
    verifyEq(Diff.run("a", "a"), Delta[,])
    
    // different with the same length
    verifyEq(Diff.run("abcd", "0123"), [Delta(0..<4, 0..<4)])    
    
    // from wiki
    verifyEq(Diff.run("abcdfghjqz", "abcdefgijkrxyz"), [Delta(4..<4, 4..<5), Delta(6..<7, 7..<8), Delta(8..<9, 9..<13)])
    
    // numbers
    verifyEq(
      Diff.run([1,2,4,7,9,35,56,58,76], [1,2,4,76,9,35,56,58,7]), 
      [Delta(3..<4, 3..<4), Delta(8..<9, 8..<9)])
  }
  
  Void testMatthias() {
    // completely different
    verifyEq(Diff.run("abcd", "012345678"), [Delta(0..<4, 0..<9)])
    
    // same sequence
    verifyEq(Diff.run("abcd", "abcd"), Delta[,])
    
    // snake
    verifyEq(Diff.run("abcdef", "bcdefx"), [Delta(0..<1, 0..<0), Delta(6..<6, 5..<6)])
    
    // insert (repro20020920)
    verifyEq(
      Diff.run(
      // indexes
      // 0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16  
      ["c1", "a","c2", "b", "c", "d", "e", "g", "h", "i", "j","c3", "k", "l"], 
      ["C1", "a","C2", "b", "c", "d", "e","I1", "e", "g", "h", "i", "j","C3", "k","I2", "l"]),
      // result
      [Delta(0..<1, 0..<1), Delta(2..<3, 2..<3), Delta(7..<7, 7..<9), Delta(11..<12, 13..<14), Delta(13..<13, 15..<16)]
    )
    
    // reverse insert (repro20030207)
    verifyEq(Diff.run("F", "0F1234567"), [Delta(0..<0, 0..<1), Delta(1..<1, 2..<9)])
    
    // Hello, world (repro20030409)
    verifyEq(Diff.run("HELLO\nWORLD".splitLines, "\n\nhello\n\n\n\nworld\n".splitLines), 
      [Delta(0..<2, 0..<8)])
    
    // some diffs
    verifyEq(Diff.run("ab-cdeff", "abxcef"), [Delta(2..<3, 2..<3), Delta(4..<5, 4..<4), Delta(7..<8, 6..<6)])

    // one change within long chain of repeats (not optimal because minimal is false)
    verifyEq(Diff.run("aaaaaaaaaa", "aaaa-aaaaa"), [Delta(4..<4, 4..<5), Delta(9..<10, 10..<10)])
  }
  
  Void testMinimal() {
    // not minimal set
    verifyEq(Diff.run("aa", "-a", false), [Delta(0..<0, 0..<1), Delta(1..<2, 2..<2)])
    // the same, but minimal set
    verifyEq(Diff.run("aa", "-a", true), [Delta(0..<1, 0..<1)])
    
    // one change within long chain of repeats with minimal is true
    verifyEq(Diff.run("aaaaaaaaaa", "aaaa-aaaaa", true), [Delta(4..<5, 4..<5)])
    
    // everything from testBase, but with minimal flag set explicitly
    baseTest(true)
    baseTest(false)
  }
  
  private Void baseTest(Bool minimal) {
    // empty / empty
    verifyEq(Diff.run("", "", minimal), Delta[,])
    
    // empty / non-empty
    verifyEq(Diff.run("", "a", minimal), [Delta(0..<0, 0..<1)])
    
    // non-empty / empty
    verifyEq(Diff.run("a", "", minimal), [Delta(0..<1, 0..<0)])
    
    // same sequence
    verifyEq(Diff.run("a", "a", minimal), Delta[,])
    
    // different with the same length
    verifyEq(Diff.run("abcd", "0123", minimal), [Delta(0..<4, 0..<4)])    
    
    // from wiki
    verifyEq(Diff.run("abcdfghjqz", "abcdefgijkrxyz", minimal), 
      [Delta(4..<4, 4..<5), Delta(6..<7, 7..<8), Delta(8..<9, 9..<13)])
    
    // numbers
    verifyEq(
      Diff.run([1,2,4,7,9,35,56,58,76], [1,2,4,76,9,35,56,58,7], minimal), 
      [Delta(3..<4, 3..<4), Delta(8..<9, 8..<9)])
  }
  
}
