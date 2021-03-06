package tink.url;

/**
 * Represents a host, i.e. a hostname and an additional port.
 * May be accessed when null.
 */
abstract Host(String) to String {
  public var name(get, never):Null<String>;
  public var port(get, never):Null<Int>;
  
  public inline function new(name:String, ?port:Int)
    this = 
      if (port == null) name;
      else if (port > 65535 || port <= 0) throw 'Invalid port';
      else '$name:$port';
      
  inline function get_name()
    return
      if (this == null) null;
      else switch this.split(']') {
          case [v]: v.split(':')[0]; // ipv4
          case [v, _]: v + ']'; // ipv6
          default: throw 'assert';
      }
      
  inline function get_port()
    return
      if (this == null) null;
      else 
        switch this.split(']') {
          case [v] | [_, v]: 
              switch v.split(':')[1] {
                  case null: null;
                  case p: Std.parseInt(p);
              }
          default: throw 'assert';
        }
}