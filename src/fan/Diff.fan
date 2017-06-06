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

@Js
internal class Snake {
  Int x := 0
  Int y := 0
}

** This class implements the Difference Algorithm published in
** "An O(ND) Difference Algorithm and its Variations" by Eugene Myers
** Algorithmica Vol. 1 No. 2, 1986, p 251.
** (linear space version).
** 
** Some optimizations are also applied to help the main algorithm.
@Js
class Diff
{
  ** Sequence A
  private DiffData a
  
  ** Sequence B
  private DiffData b
  
  ** Total number of elements in the both sequences.
  ** Equivivalent elements count as 1. 
  private Int total

  ** If true, a guaranteed minimal set of deltas is returned. This may lead to major
  ** performance loss.  
  private Bool minimal
  
  ** 'a' and 'b' is element sequences. They must have 'each(|Obj|)' method.
  ** For convenience, 'eachLine' is also supported, so you can pass 'InStream' as 
  ** a sequence of lines. 
  ** 
  ** This is not required, but if 'seq' has 'size' slot, which is an 'Int' field or a method with no params
  ** and 'Int' return type, it's assumed that this slot returns the sequence's size.  
  ** It will be utilized for better performance.
  ** Providing size of the sequence will also save some memory, because there will be no unused capacity.
  ** 
  ** If 'minimal' is true, a guaranteed minimal set of deltas is returned. This may lead to major
  ** performance loss.  
  ** 
  ** Returns a array of Deltas that describe the differences.
  static Delta[] run(Obj a, Obj b, Bool minimal := false) {
    d := Diff(a, b, minimal)
    return d.diff
  }
  
  private new make(Obj a, Obj b, Bool minimal) {
    this.minimal = minimal
    equivStore := Obj:Int[:]
    this.a = DiffData(a, equivStore)
    this.b = DiffData(b, equivStore)
    total = equivStore.size
  }
  
  ** Returns a array of Deltas that describe the differences.
  private Delta[] diff() {    
    a.findEssential(b, total, minimal)
    b.findEssential(a, total, minimal)
    max := a.essentialIndex.size + b.essentialIndex.size + 1
    vectorSize := 2 * max + 2
    // vector for the (0,0) to (x,y) search
    downVector := Int[,] { capacity = vectorSize }.fill(0, vectorSize)
    // vector for the (u,v) to (N,M) search
    upVector := Int[,] { capacity = vectorSize }.fill(0, vectorSize)
    lcs(0, a.essentialIndex.size, 0, b.essentialIndex.size, downVector, upVector)
    // TODO: add blank lines optimization (like in GNU diff)
    return createDeltas
  }
  
  ** Scan the tables of which lines are inserted and deleted,
  ** producing an edit script in forward order.  
  private Delta[] createDeltas() {
    res := Delta[,]
    startA := 0
    startB := 0
    lineA := 0
    lineB := 0
    while (lineA < a.data.size || lineB < b.data.size) {
      if (lineA < a.data.size && true != a.modified[lineA] && lineB < b.data.size && true != b.modified[lineB]) {
        // equal lines
        lineA++          
        lineB++
      } else {
        // maybe deleted and/or inserted lines
        startA = lineA
        startB = lineB
        
        while (lineA < a.data.size && (lineB >= b.data.size || true == a.modified[lineA])) {
          lineA++          
        }
        
        while (lineB < b.data.size && (lineA >= a.data.size || true == b.modified[lineB])) {
          lineB++          
        }
        
        if ((startA < lineA) || (startB < lineB)) {
          res.add(Delta(startA..<lineA, startB..<lineB))
        }
      }
    } // while  
    return res
  }  
  
  ** This is the algorithm to find the Shortest Middle Snake (SMS).
  ** 'lowerA' - lower bound of the actual range in sequence A
  ** 'UpperA' - upper bound of the actual range in sequence A (exclusive)
  ** 'lowerB' - lower bound of the actual range in sequence B
  ** 'upperB' - upper bound of the actual range in sequence B (exclusive)
  ** 'downVector' - a vector for the (0,0) to (x,y) search. Passed as a parameter for speed reasons.
  ** 'UpVector' - a vector for the (u,v) to (N,M) search. Passed as a parameter for speed reasons.
  ** Returns a record containing x,y
  private Snake sms(Int lowerA, Int upperA, Int lowerB, Int upperB, Int[] downVector, Int[] upVector) {  
    max := a.essentialIndex.size + b.essentialIndex.size + 1
  
    downK := lowerA - lowerB // the k-line to start the forward search
    upK := upperA - upperB // the k-line to start the reverse search
  
    delta := (upperA - lowerA) - (upperB - lowerB)
    oddDelta := 0 != delta % 2 
  
    // The vectors in the publication accepts negative indexes. the vectors implemented here are 0-based
    // and are access using a specific offset: UpOffset UpVector and DownOffset for DownVektor
    downOffset := max - downK
    upOffset := max - upK
  
    maxD := ((upperA - lowerA + upperB - lowerB) / 2) + 1
  
    // init vectors
    downVector[downOffset + downK + 1] = lowerA
    upVector[upOffset + upK - 1] = upperA

    x := 0
    y := 0
    ret := Snake()
    for (d := 0; d <= maxD; ++d) {  
      // Extend the forward path.
      for (k := downK - d; k <= downK + d; k += 2) {
        // find the only or better starting point
        x = 0
        if (k == downK - d) {
          x = downVector[downOffset + k + 1] // down
        } else {
          x = downVector[downOffset + k - 1] + 1 // a step to the right
          if ((k < downK + d) && (downVector[downOffset + k + 1] >= x))
            x = downVector[downOffset + k + 1] // down
        }
        y = x - k
  
        // find the end of the furthest reaching forward D-path in diagonal k.
        while ((x < upperA) && (y < upperB) && (a.essential(x) == b.essential(y))) {
          x++
          y++
        }
        downVector[downOffset + k] = x
  
        // overlap ?
        if (oddDelta && (upK - d < k) && (k < upK + d)) {
          if (upVector[upOffset + k] <= downVector[downOffset + k]) {
            ret.x = downVector[downOffset + k]
            ret.y = downVector[downOffset + k] - k
            return ret
          }
        } 
      } // for k
  
      // Extend the reverse path.
      for (k := upK - d; k <= upK + d; k += 2) {
        // find the only or better starting point
        x = 0
        if (k == upK + d) {
          x = upVector[upOffset + k - 1] // up
        } else {
          x = upVector[upOffset + k + 1] - 1 // left
          if ((k > upK - d) && (upVector[upOffset + k - 1] < x))
            x = upVector[upOffset + k - 1] // up
        } // if
        y = x - k
  
        while ((x > lowerA) && (y > lowerB) && (a.essential(x - 1) == b.essential(y - 1))) {
          x--
          y--
        }
        upVector[upOffset + k] = x
  
        // overlap ?
        if (!oddDelta && (downK - d <= k) && (k <= downK + d)) {
          if (upVector[upOffset + k] <= downVector[downOffset + k]) {
            ret.x = downVector[downOffset + k]
            ret.y = downVector[downOffset + k] - k
            return ret
          }
        }
  
      } // for k  
    } // for D
  
    throw Err("the algorithm should never come here.")
  } 
  
  ** This is the divide-and-conquer implementation of the longes common-subsequence (LCS) 
  ** algorithm.
  ** The published algorithm passes recursively parts of the A and B sequences.
  ** To avoid copying these arrays the lower and upper bounds are passed while the sequences stay constant.
  ** 'lowerA' - lower bound of the actual range in sequence A
  ** 'UpperA' - upper bound of the actual range in sequence A (exclusive)
  ** 'lowerB' - lower bound of the actual range in sequence B
  ** 'upperB' - upper bound of the actual range in sequence B (exclusive)
  ** 'downVector' - a vector for the (0,0) to (x,y) search. Passed as a parameter for speed reasons.
  ** 'UpVector' - a vector for the (u,v) to (N,M) search. Passed as a parameter for speed reasons.
  private Void lcs(Int lowerA, Int upperA, Int lowerB, Int upperB, Int[] downVector, Int[] upVector) {
    // Fast walkthrough equal lines at the start
    while (lowerA < upperA && lowerB < upperB && a.essential(lowerA) == b.essential(lowerB)) {
      lowerA++
      lowerB++
    }  
    // Fast walkthrough equal lines at the end
    while (lowerA < upperA && lowerB < upperB && a.essential(upperA - 1) == b.essential(upperB - 1)) {
      --upperA
      --upperB
    }
  
    if (lowerA == upperA) {
      // mark as inserted lines.
      while (lowerB < upperB) {
        b.modified[b.essentialIndex[lowerB++]] = true
      }  
    } else if (lowerB == upperB) {
      // mark as deleted lines.
      while (lowerA < upperA) {
        a.modified[a.essentialIndex[lowerA++]] = true        
      }  
    } else {
      // Find the middle snake and length of an optimal path for A and B
      snake := sms(lowerA, upperA, lowerB, upperB, downVector, upVector)
      // The path is from LowerX to (x,y) and (x,y) to UpperX
      lcs(lowerA, snake.x, lowerB, snake.y, downVector, upVector)
      lcs(snake.x, upperA, snake.y, upperB, downVector, upVector) 
    }
  }
  
}
