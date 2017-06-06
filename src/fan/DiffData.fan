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

** Data of one sequence being compared.
@Js
internal class DiffData
{
  ** Elements
  Int[] data  // this is actually const, but setting this to const would decrease performance
  
  ** Modified flag.
  Bool?[] modified

  ** Indexes of elements which are found in the other sequence.
  ** The algorithm works with these elements, skipping the other (unique) elements,
  ** which are obvious changes.
  Int[] essentialIndex := [,]
  
  ** 'seq' is an element sequence. It must have 'each(|Obj|)' method.
  ** 'eachLine' is also supported.
  ** This is not required, but if 'seq' has 'size' slot, it will be utilized for better performance.
  ** 
  ** 'equivStore' is a storage for equivalence numbers. It must be able to store Obj:Int pairs and support 
  ** 'get' and 'set' methods for them. It also must have 'size' field. 
  ** For now, this is just a map Obj:Int. But we may replace it (or provide a way to replace it by the user) with
  ** a more sophisticated storage, e.g. to avoid storing all items in RAM.
  new make(Obj seq, Obj:Int equivStore) {
    data = readSeq(seq, allocData(seq), equivStore)
    modified = Bool?[,] { size = data.size }
  }
  
  private static Int[] allocData(Obj seq) {
    s := seq.typeof.slot("size", false)
    cap := 0
    // checking if 'size' slot is really what we expect
    if (null != s) {
      if (s.isField) {
        f := (Field)s
        if (Int# == f.type) {
          cap = f.get(seq)
        }
      } else if (s.isMethod) {
        m := (Method)s
        if (Int# == m.returns && m.params.isEmpty) {
          cap = m.callOn(seq, null)
        }
      }
    }
    return Int[,] {
      if (0 < cap) {
        capacity = cap
      }
    }
  }
  
  private static Int[] readSeq(Obj seq, Int[] data, Obj:Int equivStore) {
    Int equiv := equivStore.size
    f := |Obj elem| {
      Int? t := equivStore[elem]
      if (null == t) {
        equivStore.set(elem, equiv)
        data.add(equiv)
        ++equiv
      } else {
        data.add(t)
      }
    }
    if (null != seq.typeof.slot("eachLine", false)) {
      seq->eachLine(f)
    } else {
      seq->each(f)
    }
    return data
  }
  
  ** Returns an essential element.
  Int essential(Int essentialIndex) { data[this.essentialIndex[essentialIndex]] }
  
  Int?[] elemCount(Int total) {
    ret := Int?[,] { it.size = total }
    data.each { ret[it] = ret[it]?.plus(1) ?: 1 }        
    return ret
  }
  
  ** Searches essential elements. If 'minimal' is true, each element is considered essential. 
  ** Otherwise, essential elements are elements from this sequence, which are found in the other sequence, too.
  ** If an element is not found in the other sequence, obviously it's a change. 
  **  
  ** Indices of essential elements are stored in 'essentialIndex'.
  ** Non-essential elements (if any) are marked 'modified'. 
  Void findEssential(DiffData other, Int total, Bool minimal) {
    counts := minimal ? Int[,] : other.elemCount(total)
    essentialIndex = Int[,] 
    data.each |elem, i| { 
      if (minimal || 0 < counts[elem]) {
        essentialIndex.add(i)
      } else {
        modified[i] = true
      }
    }
  }
  
}
