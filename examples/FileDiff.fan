using diff

class FileExample
{
  static Void main(Str[] args) {
    if (2 > args.size) {
      echo("Compares two files line by line")
      echo("Usage: fan FileDiff.fan <file A> <file B>")
      return
    }
    inA := File(`${args[0]}`).in
    inB := File(`${args[1]}`).in
    deltas := Diff.run(inA, inB)
    deltas.each { echo("$it.a => $it.b") }
  }
}
