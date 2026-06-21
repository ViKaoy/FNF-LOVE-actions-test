local ffi = require("ffi")

ffi.cdef[[
    typedef void* jclass;
    typedef void* jobject;
    typedef void* jmethodID;
    typedef void* jstring;
    typedef union jvalue {
        uint8_t z; int8_t b; uint16_t c; int16_t s;
        int32_t i; int64_t j; float f; double d; void* l;
    } jvalue;
    void* SDL_GetAndroidJNIEnv(void);
    void* SDL_GetAndroidActivity(void);
]]

local sdl = ffi.load("SDL3")
local env = sdl.SDL_GetAndroidJNIEnv()
local activity = sdl.SDL_GetAndroidActivity()
local vtable = ffi.cast("void***", env)[0]

local FindClass = ffi.cast("jclass (*)(void*, const char*)", vtable[6])
local DeleteLocalRef = ffi.cast("void (*)(void*, jobject)", vtable[23])
local NewObjectA = ffi.cast("jobject (*)(void*, jclass, jmethodID, jvalue*)", vtable[30])
local GetObjectClass = ffi.cast("jclass (*)(void*, jobject)", vtable[31])
local GetMethodID = ffi.cast("jmethodID (*)(void*, jclass, const char*, const char*)", vtable[33])
local CallObjectMethodA = ffi.cast("jobject (*)(void*, jobject, jmethodID, jvalue*)", vtable[36])
local CallVoidMethodA = ffi.cast("void (*)(void*, jobject, jmethodID, jvalue*)", vtable[63])
local NewStringUTF = ffi.cast("jstring (*)(void*, const char*)", vtable[167])

local TYPES = {
    zip   = "application/zip",  json  = "application/json",
    xml   = "application/xml",  txt   = "text/plain",
    image = "image/png",        audio = "audio/*",
    video = "video/ogv",        any   = "*/*"
}

local AndroidFilePicker = {}

function AndroidFilePicker.open(filetype)
    filetype = TYPES[filetype] or filetype or "application/zip"

    local intentClass = FindClass(env, "android/content/Intent")
    local intentInit = GetMethodID(env, intentClass, "<init>", "(Ljava/lang/String;)V")
    local actionStr = NewStringUTF(env, "android.intent.action.OPEN_DOCUMENT")
    local args1 = ffi.new("jvalue[1]"); args1[0].l = actionStr
    local intentObj = NewObjectA(env, intentClass, intentInit, args1)

    local setType = GetMethodID(env, intentClass, "setType", "(Ljava/lang/String;)Landroid/content/Intent;")
    local typeStr = NewStringUTF(env, filetype)
    local args2   = ffi.new("jvalue[1]"); args2[0].l = typeStr
    CallObjectMethodA(env, intentObj, setType, args2)

    local addCat = GetMethodID(env, intentClass, "addCategory", "(Ljava/lang/String;)Landroid/content/Intent;")
    local catStr = NewStringUTF(env, "android.intent.category.OPENABLE")
    local args3  = ffi.new("jvalue[1]"); args3[0].l = catStr
    CallObjectMethodA(env, intentObj, addCat, args3)

    local actClass = GetObjectClass(env, activity)
    local startMethod = GetMethodID(env, actClass, "startActivityForResult", "(Landroid/content/Intent;I)V")
    local args4 = ffi.new("jvalue[2]"); args4[0].l = intentObj; args4[1].i = 42
    CallVoidMethodA(env, activity, startMethod, args4)

    DeleteLocalRef(env, actionStr)
    DeleteLocalRef(env, typeStr)
    DeleteLocalRef(env, catStr)
    DeleteLocalRef(env, intentClass)
    DeleteLocalRef(env, intentObj)
    DeleteLocalRef(env, actClass)
end

return AndroidFilePicker
