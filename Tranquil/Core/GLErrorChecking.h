#ifndef _Tranquil_GLErrorChecking_h
#define _Tranquil_GLErrorChecking_h

#ifdef DEBUG

#include <OpenGL/gl.h>

#include <stdlib.h>
#include <assert.h>

#define TCheckGLError()\
{\
	for ( GLenum Error = glGetError( ); ( GL_NO_ERROR != Error ); Error = glGetError( ) )\
	{\
		switch ( Error )\
		{\
			case GL_INVALID_ENUM:      printf( "\n%s\n\n", "GL_INVALID_ENUM"      ); assert( 0 ); break;\
			case GL_INVALID_VALUE:     printf( "\n%s\n\n", "GL_INVALID_VALUE"     ); assert( 0 ); break;\
			case GL_INVALID_OPERATION: printf( "\n%s\n\n", "GL_INVALID_OPERATION" ); assert( 0 ); break;\
			case GL_STACK_OVERFLOW:    printf( "\n%s\n\n", "GL_STACK_OVERFLOW"    ); assert( 0 ); break;\
			case GL_STACK_UNDERFLOW:   printf( "\n%s\n\n", "GL_STACK_UNDERFLOW"   ); assert( 0 ); break;\
			case GL_OUT_OF_MEMORY:     printf( "\n%s\n\n", "GL_OUT_OF_MEMORY"     ); assert( 0 ); break;\
			default:                                                                              break;\
		}\
	}\
}

#define TCheckFramebufferStatus( )\
{\
	switch ( glCheckFramebufferStatus( GL_FRAMEBUFFER ) )\
	{\
	case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:         printf( "\n%s\n\n", "GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT"         ); assert( 0 ); break;\
	case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: printf( "\n%s\n\n", "GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT" ); assert( 0 ); break;\
	case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER:        printf( "\n%s\n\n", "GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER"        ); assert( 0 ); break;\
	case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER:        printf( "\n%s\n\n", "GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER"        ); assert( 0 ); break;\
	case GL_FRAMEBUFFER_UNSUPPORTED:                   printf( "\n%s\n\n", "GL_FRAMEBUFFER_UNSUPPORTED"                   ); assert( 0 ); break;\
	case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE:        printf( "\n%s\n\n", "GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE"        ); assert( 0 ); break;\
	case GL_FRAMEBUFFER_UNDEFINED:                     printf( "\n%s\n\n", "GL_FRAMEBUFFER_UNDEFINED"                     ); assert( 0 ); break;\
	default:                                                                                                                              break;\
	}\
}

#define TGetShaderInfoLog( Shader, Source )\
{\
	GLint   Status, Count;\
	GLchar *Error;\
	\
	glGetShaderiv( Shader, GL_COMPILE_STATUS, &Status );\
	if ( !Status )\
	{\
		glGetShaderiv( Shader, GL_INFO_LOG_LENGTH, &Count );\
		if ( Count > 0 )\
		{\
			glGetShaderInfoLog( Shader, Count, NULL, ( Error = calloc( 1, Count ) ) );\
			printf( "Shaderlog: %s\n\n%s\n", Source, Error );\
			free( Error );\
			\
			assert( 0 );\
		}\
	}\
}

#define TClearGLErrors() while(glGetError() != GL_NO_ERROR)

#else
#define TCheckGLError( )
#define TCheckFramebufferStatus( )
#define TGetShaderInfoLog( Shader, Source )
#define TClearGLErrors()

#endif
#endif
