#include "ruby.h"
#include "rand.h"

static VALUE CryptModule;
static VALUE ISAACClass;

static void ISAAC_free( randctx* ctx ) {
  if ( ctx ) {
    xfree( ctx );
  }
}

static VALUE ISAAC_alloc( VALUE klass ) {
  randctx *ctx;

  return Data_Make_Struct( klass, randctx, NULL, ISAAC_free, ctx );
}

static VALUE ISAAC_initialize( VALUE self, VALUE args ) {
  VALUE _seed ;
  long len = RARRAY_LEN( args );
  if ( len == 0 ) {
    _seed = Qtrue;
  } else {
    _seed = rb_ary_entry( args, 0 );
  }

  return rb_funcall( self, rb_intern( "srand" ), 1, _seed );
}

static VALUE ISAAC_srand( VALUE self, VALUE args ) {
  FILE *fh;
  uint32_t num = 0;
  size_t nread;
  VALUE _seed;
  VALUE old_seed;
  VALUE seed_prng;
  VALUE random_argv[1];
  VALUE rnd_source = Qnil;
  int x;
  long len = RARRAY_LEN( args );
  randctx *ctx;

  if ( len == 0 ) {
    _seed = Qtrue;
  } else {
    _seed = rb_ary_entry( args, 0 );
  }

  if ( ( _seed == Qtrue ) || ( _seed == Qfalse ) ) {
    rnd_source = ( _seed == Qtrue ) ? rb_str_new2("/dev/urandom") : rb_str_new2("/dev/random");
  }

  Data_Get_Struct( self, randctx, ctx );
  MEMZERO( ctx, randctx, 1 );

  if ( ( rnd_source != Qnil ) && ( rb_funcall( rb_mFileTest, rb_intern("exist?"), 1, rnd_source ) == Qtrue ) ) {
    fh = fopen("/dev/urandom","r");
    for ( x = RANDSIZ - 1; x >= 0; x-- ) {
      nread = fread(&num, sizeof(uint32_t), 1, fh);
      if ( nread == 0 ) {
        x++;
        continue;
      }
      ctx->randrsl[x] = num;
    }
    fclose(fh);
  } else {
    if ( rnd_source != Qnil ) {
      _seed = Qnil;
    }
    if ( rb_funcall( _seed, rb_intern( "respond_to?" ), 1, rb_str_new2("rand") ) == Qtrue ) {
      seed_prng = _seed;
    } else {
      random_argv[0] = _seed;
      seed_prng = rb_class_new_instance( 1, random_argv, rb_const_get( rb_const_get( rb_cObject, rb_intern( "Crypt" ) ), rb_intern( "Xorshift64Star" ) ) );
      _seed = rb_funcall( seed_prng, rb_intern( "seed" ), 0 );
      rb_iv_set( self, "@seed_prng", seed_prng );
    }
    for ( x = RANDSIZ - 1; x >= 0; x-- ) {
      ctx->randrsl[x] = FIX2ULONG( rb_funcall( seed_prng, rb_intern( "rand" ), 1, ULONG2NUM(4294967296) ) );
    }
  }
  randinit(ctx, 1);

  rb_iv_set( self, "@seed", ( ( rnd_source == Qtrue ) || ( rnd_source == Qfalse ) ) ? rnd_source : _seed );
  old_seed = rb_iv_get( self, "@seed");

  return old_seed;
}

static VALUE ISAAC_rand( VALUE self, VALUE args ) {
  uint32_t limit;
  long len = RARRAY_LEN( args );
  VALUE arg;
  short arg_is_a_range = 0;
  ID id_min;
  VALUE val_min = 0;
  ID id_max;
  randctx *ctx;

  arg = rb_ary_entry( args, 0 );

  if ( len == 0 ) {
    limit = 0;
  } else if ( rb_obj_class( arg ) == rb_cRange ) {
    arg_is_a_range = 1;
    id_min = rb_intern("min");
    id_max = rb_intern("max");
    val_min = rb_funcall( arg, id_min, 0 );
    limit = NUM2ULONG( rb_funcall( arg, id_max, 0 ) ) - NUM2ULONG( val_min );
  } else {
    limit = NUM2ULONG( rb_ary_entry( args, 0 ) );
  }

  Data_Get_Struct( self, randctx, ctx );
  if ( !ctx->randcnt-- ) {
    isaac( ctx );
    ctx->randcnt = RANDSIZ - 1;
  }

  if ( limit == 0 ) {
    return rb_float_new( ctx->randrsl[ctx->randcnt] / 4294967296.0 );
  } else if ( arg_is_a_range ) {
    return ULONG2NUM( NUM2ULONG( val_min ) + ( ctx->randrsl[ctx->randcnt] % limit ) );
  } else {
    return ULONG2NUM( ctx->randrsl[ctx->randcnt] % limit );
  }
}

static VALUE ISAAC_marshal_dump( VALUE self ) {
  randctx *ctx;
  int i;
  int ary_size = sizeof( randctx ) / sizeof( ub4 );
  VALUE ary;

  Data_Get_Struct( self, randctx, ctx );
    
  ary = rb_ary_new2( ary_size );
  for ( i = 0; i < ary_size; i++ ) {
      rb_ary_push( ary, ULONG2NUM(((ub4 *)ctx)[i]));
  }
    
  return ary;
}

static VALUE ISAAC_marshal_load( VALUE self, VALUE ary ) {
  randctx *ctx;
  int i;
  int ary_size = sizeof( randctx ) / sizeof( ub4 );

  Data_Get_Struct( self, randctx, ctx );

  if ( RARRAY_LEN(ary) != ary_size )
    rb_raise( rb_eArgError, "bad length in loaded ISAAC data" );

  for ( i = 0; i < ary_size; i++ ) {
    ((ub4 *)ctx)[i] = NUM2ULONG(RARRAY_PTR(ary)[i] );
  }
    
  return self;
}

static VALUE ISAAC_seed( VALUE self ) {
  return rb_iv_get( self, "@seed");
}

static VALUE ISAAC_new_seed( VALUE self ) {
  return rb_funcall( rb_iv_get( self, "@seed_prng" ), rb_intern("new_seed"), 0 );
}

int compare_ctx( randctx* ctx1, randctx* ctx2 ) {
  int x;
  for ( x = RANDSIZ - 1; x >= 0; x-- ) {
    if ( ctx1->randrsl[x] != ctx2->randrsl[x] ) return 0;
  }

  return 1;
}

static VALUE ISAAC_eq( VALUE self, VALUE v ) {
  randctx* ctx1;
  randctx* ctx2;

  Data_Get_Struct( self, randctx, ctx1 );
  Data_Get_Struct( v, randctx, ctx2 );

  return ( ( rb_obj_classname( self ) == rb_obj_classname( v ) ) && ( compare_ctx( ctx1, ctx2 ) ) ) ? Qtrue : Qfalse ;
}

static VALUE ISAAC_bytes( VALUE self, VALUE count ) {
  uint64_t bytes = NUM2ULL( count );
  char buf[ bytes + 5 ]; 
  uint64_t i = 0;
  randctx* ctx;

  Data_Get_Struct( self, randctx, ctx );
  for( i = 0; i < bytes; i = i + 4 ) {

    if ( !ctx->randcnt-- ) {
      isaac( ctx );
      ctx->randcnt = RANDSIZ - 1;
    }

    // snprintf( &buf[ i ], 5, "%lu", ctx->randrsl[ctx->randcnt] ); 
    buf[ i ] = ctx->randrsl[ctx->randcnt];
    buf[ i + 1 ] = ctx->randrsl[ctx->randcnt] >> 8;
    buf[ i + 2 ] = ctx->randrsl[ctx->randcnt] >> 16;
    buf[ i + 3 ] = ctx->randrsl[ctx->randcnt] >> 24;
  }

  return rb_str_new( buf, bytes );
}

void Init_ext() {
  CryptModule = rb_define_module( "Crypt" );
  ISAACClass = rb_define_class_under( CryptModule, "ISAAC", rb_cObject );
        
  rb_define_alloc_func( ISAACClass, ISAAC_alloc );
  rb_define_method( ISAACClass, "initialize", ISAAC_initialize, -2 );
  rb_define_method( ISAACClass, "srand", ISAAC_srand, -2 );
  rb_define_method( ISAACClass, "rand", ISAAC_rand, -2 );
  rb_define_method( ISAACClass, "seed", ISAAC_seed, 0 );
  rb_define_method( ISAACClass, "new_seed", ISAAC_new_seed, 0 );
  rb_define_method( ISAACClass, "==", ISAAC_eq, 1 );
  rb_define_method( ISAACClass, "bytes", ISAAC_bytes, 1 );
  rb_define_method( ISAACClass, "marshal_dump", ISAAC_marshal_dump, 0 );
  rb_define_method( ISAACClass, "marshal_load", ISAAC_marshal_load, 1 );
    
  rb_const_set( ISAACClass, rb_intern("RANDSIZ"), ULONG2NUM(RANDSIZ) );
  rb_require( "crypt/isaac/version.rb" );
}
