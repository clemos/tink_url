package tink.url;

import haxe.DynamicAccess;
import tink.core.Named;

using StringTools;

abstract Query(String) from String to String {  
  
  public inline function parse() 
    return iterator();
  
  public inline function iterator() 
    return parseString(this);
  
  @:to public function toMap():Map<String, String>
    return [for (p in iterator()) p.name => p.value];
  
  @:from static function ofObj(v:Dynamic<String>) {
    var ret = new QueryStringBuilder(),
        v:DynamicAccess<String> = v;
        
    for (k in v.keys())
      ret.add(k, v[k]);
      
    return ret.toString();
  }    
  
  static public inline function build():QueryStringBuilder 
    return new QueryStringBuilder();
   
  static public inline function parseString(s:String, sep:String = '&', set:String = '=', pos:Int = 0)
    return new QueryStringParser(s, sep, set, pos);
    
}

abstract QueryStringBuilder(Array<String>) {
  
  public inline function new() {
    this = [];
  }
  
  public inline function add(name:String, value:String):QueryStringBuilder {
    this.push(name.urlEncode() + '=' + value.urlEncode());
    return cast this;
  }
  
  public inline function toString()
    return this.join('&');
}

typedef QueryStringParam = Named<String>;

private class QueryStringParser {
  
  var s:String;
  var sep:String;
  var set:String;
  var pos:Int;
  
  public function new(s, sep, set, pos) {
    this.s = switch s {
      case null: '';
      default: s;
    }
    this.sep = sep;
    this.set = set;
    this.pos = pos;
  }
  
  public function hasNext() 
    return pos < s.length;
    
  public function next() {
    var next = s.indexOf(sep, pos);
    
    if (next == -1)
      next = s.length;
    
    var split = s.indexOf(set, pos);
    var start = pos;
      
    pos = next + sep.length;
    
    return 
      if (split == -1 || split > next)
        new QueryStringParam(trimmedSub(s, start, next).urlDecode(), '');
      else
        new QueryStringParam(trimmedSub(s, start, split).urlDecode(), trimmedSub(s, split + set.length, next).urlDecode());
  }

  static function trimmedSub(s:String, start:Int, end:Int) {
    
    while (s.fastCodeAt(start) <= 32) 
      start++;
    
    if (end < s.length - 1)
      while (s.fastCodeAt(end) <= 32) 
        end--;
      
    return s.substring(start, end);
  }  
  
}