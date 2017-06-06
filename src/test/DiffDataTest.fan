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

class DiffDataTest : Test
{
  
  Void testDiffData() {
    //  empty / empty
    verifyEq(essentials("", ""), Int[,])
    
    //  non-empty / empty
    verifyEq(essentials("a", ""), Int[,])
    
    //  empty / non-empty
    verifyEq(essentials("", "a"), Int[,])

    // 0 essencials (completely different)
    verifyEq(essentials("a", "b"), Int[,])
    verifyEq(essentials("aaa", "bbbb"), Int[,])
    verifyEq(essentials("sdfsdfsd", "6464468"), Int[,])

    // same sequence
    verifyEq(essentials("a", "a"), [0])
    verifyEq(essentials("ab", "ab"), [0, 1])
    verifyEq(essentials("abc", "abc"), [0, 1, 2])

    // reverse
    verifyEq(essentials("ba", "ab"), [0, 1])
    verifyEq(essentials("cba", "abc"), [0, 1, 2])
    
    // some essentials
    verifyEq(essentials("abcdef", "abqw"), [0, 1])
    verifyEq(essentials("abcdef", "efqw"), [4, 5])
    verifyEq(essentials("a0b1c2", "888-2-88-0-33"), [1, 5])
    
    // minimal essentials (should always be [0..<sequence size])
    verifyEq(essentials("", "", true), Int[,])
    verifyEq(essentials("", "a", true), Int[,])
    verifyEq(essentials("a", "", true), [0])
    verifyEq(essentials("a", "a", true), [0])
    verifyEq(essentials("a", "b", true), [0])
    verifyEq(essentials("abcdef", "abqw", true), [0, 1, 2, 3, 4, 5])
  }
  
  ** Returns 'essencialIndex' for the sequence A
  private Int[] essentials(Obj a, Obj b, Bool minimal := false) {
    eq := Obj:Int[:]
    da := DiffData(a, eq)
    db := DiffData(b, eq)
    da.findEssential(db, eq.size, minimal)
    return da.essentialIndex
  }
  
  Void testCapacity() {
    eq := Obj:Int[:]
    
    // calculating default capacity
    t := Int[,]
    t.add(0)
    t.add(1)
    defCap := t.capacity

    // With no size, default capacity should be set
    verifyEq(DiffData(SeqNoSize(), eq).data.capacity, defCap)
    
    // Checking correct size
    verifyEq(DiffData(SeqCorrectSizeField0(), eq).data.capacity, 2)
    verifyEq(DiffData(SeqCorrectSizeField1(), eq).data.capacity, 2)
    
    // Checking correct field, but incorrect size
    verifyEq(DiffData(SeqMisleadingSizeField0(), eq).data.capacity, 4)
    verifyEq(DiffData(SeqMisleadingSizeField1(), eq).data.capacity, defCap)
    
    // Checking incorrect size field. In this case, default capacity should be set
    verifyEq(DiffData(SeqIncorrectSizeField0(), eq).data.capacity, defCap)
    verifyEq(DiffData(SeqIncorrectSizeField1(), eq).data.capacity, defCap)
  }
}

internal class SeqNoSize {
  Void each(Func f) { f(0); f(1) }
}

internal class SeqCorrectSizeField0 {
  Int size := 2
  Void each(Func f) { f(0); f(1) }
}

internal class SeqCorrectSizeField1 {
  Int size() { 2 }
  Void each(Func f) { f(0); f(1) }
}

internal class SeqMisleadingSizeField0 {
  Int size() { 4 }
  Void each(Func f) { f(0); f(1) }
}

internal class SeqMisleadingSizeField1 {
  Int size() { 1 }
  Void each(Func f) { f(0); f(1) }
}

internal class SeqIncorrectSizeField0 {
  Float size := 2f
  Void each(Func f) { f(0); f(1) }
}

internal class SeqIncorrectSizeField1 {
  Void size() {}
  Void each(Func f) { f(0); f(1) }
}

internal class SeqIncorrectSizeField2 {
  Int size(Int a) { 2 }
  Void each(Func f) { f(0); f(1) }
}
