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

** Describes a single difference in sequences.
@Js
const class Delta
{
  
  ** Range of items in the A sequence.
  const Range a
  
  ** Range of items in the B sequence, which corresponds to 'a' range in 'A' sequence.
  const Range b
  
  new make(Range a, Range b) {
    this.a = a
    this.b = b
  }

  override Str toStr() { "Delta($a, $b)" }
  
  override Int hash() { a.hash.xor(b.hash.shiftl(16)) }

  override Bool equals(Obj? obj)
  {
    that := obj as Delta
    if (that == null) return false
    return this.a == that.a && this.b == that.b
  }

}
