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

local AndroidFilePicker = {}
AndroidFilePicker.__index = AndroidFilePicker

function AndroidFilePicker.new()
    local self = setmetatable({}, AndroidFilePicker)
    self.env = sdl.SDL_GetAndroidJNIEnv()
    self.activity = sdl.SDL_GetAndroidActivity()
    local vtable  = ffi.cast("void***", self.env)[0]
    self.FindClass = ffi.cast("jclass  (*)(void*, const char*)", vtable[6])
    self.DeleteLocalRef = ffi.cast("void    (*)(void*, jobject)",  vtable[21])
    self.NewObjectA= ffi.cast("jobject (*)(void*, jclass, jmethodID, jvalue*)", vtable[28])
    self.GetObjectClass = ffi.cast("jclass  (*)(void*, jobject)", vtable[29])
    self.GetMethodID= ffi.cast("jmethodID (*)(void*, jclass, const char*, const char*)", vtable[31])
    self.CallObjectMethodA= ffi.cast("jobject (*)(void*, jobject, jmethodID, jvalue*)", vtable[34])
    self.CallVoidMethodA= ffi.cast("void    (*)(void*, jobject,    jmethodID, jvalue*)", vtable[61])
    self.NewStringUTF= ffi.cast("jstring (*)(void*, const char*)", vtable[167])
    return self
end

function AndroidFilePicker:openZIP()
    local env = self.env

    local intentClass  = self.FindClass(env, "android/content/Intent")
    local intentInit = self.GetMethodID(env, intentClass, "<init>", "(Ljava/lang/String;)V")
    local actionStr = self.NewStringUTF(env, "android.intent.action.OPEN_DOCUMENT")
    local args1 = ffi.new("jvalue[1]"); args1[0].l = actionStr
    local intentObj = self.NewObjectA(env, intentClass, intentInit, args1)

    local setType  = self.GetMethodID(env, intentClass, "setType", "(Ljava/lang/String;)Landroid/content/Intent;")
    local typeStr= self.NewStringUTF(env, "application/zip")
    local args2 = ffi.new("jvalue[1]"); args2[0].l = typeStr
    self.CallObjectMethodA(env, intentObj, setType, args2)

    local addCat = self.GetMethodID(env, intentClass, "addCategory", "(Ljava/lang/String;)Landroid/content/Intent;")
    local catStr = self.NewStringUTF(env, "android.intent.category.OPENABLE")
    local args3 = ffi.new("jvalue[1]"); args3[0].l = catStr
    self.CallObjectMethodA(env, intentObj, addCat, args3)

    local actClass= self.GetObjectClass(env, self.activity)
    local startMethod = self.GetMethodID(env, actClass, "startActivityForResult", "(Landroid/content/Intent;I)V")
    local args4 = ffi.new("jvalue[2]"); args4[0].l = intentObj; args4[1].i = 42
    self.CallVoidMethodA(env, self.activity, startMethod, args4)

    self.DeleteLocalRef(env, actionStr)
    self.DeleteLocalRef(env, typeStr)
    self.DeleteLocalRef(env, catStr)
    self.DeleteLocalRef(env, intentClass)
    self.DeleteLocalRef(env, intentObj)
    self.DeleteLocalRef(env, actClass)
end

return AndroidFilePicker
