#ifndef Tranquil_TranquilCore_h
#define Tranquil_TranquilCore_h

#define kTranquilFinishedLaunching @"kTranquilFinishedLaunching"

#import <TranquilCore/Debug.h>
#import <TranquilCore/ScriptContext.h>
#import <TranquilCore/Scene.h>
#import <TranquilCore/State.h>
#import <TranquilCore/Shader.h>
#import <TranquilCore/Debug.h>
#import <TranquilCore/Light.h>
#import <TranquilCore/TranquilPlugin.h>
#import <GLMath/GLMath.h>

// We are using double precision vertices for the time being, so we need these macros to cast uniforms to floats
// before uploading to gl. This is a workaround for a bug in MacRuby that causes it to get alignment on floats wrong
#define FCAST_VEC4(v) { (float)((v).x), (float)((v).y), (float)((v).z), (float)((v).w) }
#define FCAST_MAT4(m) { (float)((m).m00), (float)((m).m01), (float)((m).m02), (float)((m).m03), \
                        (float)((m).m10), (float)((m).m11), (float)((m).m12), (float)((m).m13), \
                        (float)((m).m20), (float)((m).m21), (float)((m).m22), (float)((m).m23), \
                        (float)((m).m30), (float)((m).m31), (float)((m).m32), (float)((m).m33), }


#endif
