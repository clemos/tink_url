package tink.url;

using haxe.io.Path;
using StringTools;

abstract Path(String) to String {
  
  public function parts()
    return this.split('/');//TODO: consider using a cache
  
  public var absolute(get, never):Bool;
    inline function get_absolute()
      return this.charAt(0) == '/';
      
  public var isDir(get, never):Bool;
    inline function get_isDir()
      return this.charAt(this.length - 1) == '/';
    
  inline function new(s) 
    this = s;
    
  public function join(that:Path):Path
    return 
      if (that == '') cast this;
      else if (that.absolute) that;
      else //it's a little heavy to run through the WHOLE normalization here, but eh ... pull requests welcome
        if (isDir) ofString(this + (that : String));
        else switch this.lastIndexOf('/') {
          case -1: that;
          case v: this.substr(0, v + 1) + that;
        }
  
  @:from static public function ofString(s:String) {//TODO: consider what to do with invalid paths, e.g. '....'
    return new Path(normalize(s));
  }
  
  static public function normalize(s:String) {
    s = s.replace('\\', '/').trim();
    if (s == '.')
      return './';
      
    var isDir = s.endsWith('/..') || s.endsWith('/') || s.endsWith('/.');
    
    var parts = [],
        isAbsolute = s.startsWith('/'),
        up = 0;
    
    for (part in s.split('/'))
      switch part.trim() {
        case '.':
        case '..': 
          if (parts.pop() == null) up++;
        case v: parts.push(v);
      }
      
    if (isAbsolute)
      parts.unshift('');
    else
      for (i in 0...up)
        parts.unshift('..');
    
    if (isDir)
      parts.push('');

    
    // drop extra slashes... 
    while( parts.length > 2 && parts[0]+parts[1] == '' ) 
      parts.shift();

    while( parts.length > 2 && parts[parts.length-1]+parts[parts.length-2] == '' ) 
      parts.pop();

    return parts.join('/');  

  }
  
  static public var root(default, null):Path = new Path('/');
}