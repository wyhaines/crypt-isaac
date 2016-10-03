#include "ruby.h"
#include <sys/types.h>
#include <unistd.h>

static VALUE CryptModule;
static VALUE Xorshift64StarClass;
static int16_t seed_counter = 0;

static void Xorshift64Star_free( uint64_t* seed ) {
  if ( seed ) {
    xfree( seed );
  }
}

static VALUE Xorshift64Star_alloc( VALUE klass ) {
  uint64_t* seed;

  return Data_Make_Struct( klass, uint64_t, NULL, Xorshift64Star_free, seed );
}

static VALUE Xorshift64Star_initialize( VALUE self, VALUE args ) {
  VALUE _seed ;
  long len = RARRAY_LEN( args );

  if ( len == 0 ) {
    _seed = rb_funcall( self, rb_intern( "srand" ), 0 );
  } else {
    _seed = rb_funcall( self, rb_intern( "srand" ), 1, rb_ary_entry( args, 0 ) );
  }

  _seed = rb_funcall( self, rb_intern( "srand" ), 1, _seed );
  rb_iv_set( self, "@old_seed", _seed );
  return _seed;
}

static VALUE to_hex_block( VALUE arg, VALUE data, int argc, VALUE* argv ) {
  return rb_funcall( arg, rb_intern( "to_s" ), 1, INT2FIX( 16 ) );
}

static VALUE Xorshift64Star_new_seed( VALUE self ) {
  VALUE now;
  VALUE ary;
  now  = rb_funcall( rb_cTime, rb_intern( "now" ), 0 );
  ary = rb_ary_new();
  seed_counter++;

  rb_ary_push( ary, rb_funcall( rb_funcall( now, rb_intern( "usec" ), 0 ), rb_intern( "%" ), 1, INT2FIX( 65536 ) ) );
  rb_ary_push( ary, rb_funcall( rb_funcall( now, rb_intern( "to_i" ), 0 ), rb_intern( "%" ), 1, INT2FIX( 65536 ) ) );
  rb_ary_push( ary, rb_funcall( INT2FIX( getpid() ), rb_intern( "%" ), 1, INT2FIX( 65536 ) ) );
  rb_ary_push( ary, INT2FIX( seed_counter ) );
  return rb_funcall( rb_funcall(
                       rb_block_call( ary, rb_intern( "collect" ), 0, 0, to_hex_block, Qnil ),
                       rb_intern( "join" ),
                       0
                     ), rb_intern( "to_i" ), 1, INT2FIX( 16 ) );
}

static VALUE Xorshift64Star_srand( VALUE self, VALUE args ) {
  uint64_t *seed;
  long len = RARRAY_LEN( args );
  VALUE _seed ;

  Data_Get_Struct( self, uint64_t, seed);

  if ( ( len == 0 ) || ( ( len == 1 ) && ( rb_ary_entry( args, 0 ) == Qnil ) ) ) {
    _seed = rb_funcall( self, rb_intern( "new_seed" ), 0 );
  } else {
    _seed = rb_ary_entry( args, 0 );
  }

  rb_iv_set( self, "@old_seed", ULL2NUM( (*seed) ) );

  (*seed) = NUM2ULL(_seed);
  return _seed;
}

static VALUE Xorshift64Star_rand( VALUE self, VALUE args ) {
  long len = RARRAY_LEN( args );
  uint64_t *seed;
  uint64_t limit;
  uint64_t random;
  Data_Get_Struct( self, uint64_t, seed );

  if ( len == 0 ) {
    limit = 0;
  } else {
    limit = NUM2ULL( rb_ary_entry( args, 0 ) );
  }

  *seed ^= *seed >> 12;
  *seed ^= *seed << 25;
  *seed ^= *seed >> 27;
  random = *seed * UINT64_C(2685821657736338717);

  if ( limit == 0 ) {
    return DBL2NUM( (double)( random / 2 ) / 9223372036854775807 );
  } else {
    return ULL2NUM( random % limit );
  }
}

static VALUE Xorshift64Star_seed(VALUE self) {
  return rb_iv_get( self, "@old_seed" );
}

static VALUE Xorshift64Star_eq(VALUE self, VALUE v) {
      return ( ( rb_obj_classname( self ) == rb_obj_classname( v ) ) && ( rb_iv_get( self, "@old_seed" ) == rb_funcall( v, rb_intern( "seed" ), 0 ) ) ) ? Qtrue : Qfalse ;
}

void Init_ext() {
  CryptModule = rb_define_module( "Crypt" );
  Xorshift64StarClass = rb_define_class_under( CryptModule, "Xorshift64Star", rb_cObject );
        
  rb_define_alloc_func( Xorshift64StarClass, Xorshift64Star_alloc );
  rb_define_method( Xorshift64StarClass, "initialize", Xorshift64Star_initialize, -2 );
  rb_define_method( Xorshift64StarClass, "srand", Xorshift64Star_srand, -2 );
  rb_define_method( Xorshift64StarClass, "rand", Xorshift64Star_rand, -2 );
  rb_define_method( Xorshift64StarClass, "new_seed", Xorshift64Star_new_seed, 0 );
  rb_define_method( Xorshift64StarClass, "seed", Xorshift64Star_seed, 0 );
  rb_define_method( Xorshift64StarClass, "==", Xorshift64Star_eq, 1 );
}
