import ffi
import std/locks
import waku/factory/waku

declareLibrary("logosdelivery")

var eventCallbackLock: Lock
initLock(eventCallbackLock)

template requireInitializedNode*(
    ctx: ptr FFIContext[Waku], opName: string, onError: untyped
) =
  if ctx.isNil():
    let errMsg {.inject.} = opName & " failed: invalid context"
    onError
  elif ctx.myLib.isNil() or ctx.myLib[].isNil():
    let errMsg {.inject.} = opName & " failed: node is not initialized"
    onError

proc logosdelivery_set_event_callback(
    ctx: ptr FFIContext[Waku], callback: FFICallBack, userData: pointer
) {.dynlib, exportc, cdecl.} =
  if ctx.isNil():
    echo "error: invalid context in logosdelivery_set_event_callback"
    return

  # prevent race conditions that might happen due incorrect usage.
  eventCallbackLock.acquire()
  defer:
    eventCallbackLock.release()

  ctx[].eventCallback = cast[pointer](callback)
  ctx[].eventUserData = userData
