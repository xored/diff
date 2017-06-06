using diff

class DiffExample
{
  static Void main(Str[] args) {
    echo("*** Strings from wiki page (http://en.wikipedia.org/wiki/Diff) ***")
    sa := "abcdfghjqz"
    sb := "abcdefgijkrxyz"
    echo("String A: $sa")
    echo("String B: $sb")
    echo(Diff.run(sa, sb))
    
    echo("\n*** List of numbers ***")
    la := [1, 2, 3, 4]
    lb := [3, 4, 1, 2]
    echo("List A: $la")
    echo("List B: $lb")
    echo(Diff.run(la, lb))
    
    echo("\n*** Example, when setting minimal flag results in shorter deltas ***")
    echo("  (setting minimal flag may decrease performance dramatically)")
    ma := "aa"
    mb := "ba"
    echo("String A: $ma")
    echo("String B: $mb")
    echo("Without minimal flag set: " + Diff.run(ma, mb))
    echo("With minimal flag set: " + Diff.run(ma, mb, true))
  }
  
}
