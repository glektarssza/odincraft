package odincraft

//-- Core Libraries
import "core:c"
import "core:mem"
import "core:strings"

//-- Vendor Libraries
import "vendor:glfw"

/*
A type alias for our window type.
*/
Window :: glfw.WindowHandle

/*
An enumeration of errors that can occur when a window is created.
*/
Window_Creation_Error :: enum {
    /*
    There were no errors.
    */
    None,

    /*
    The underlying platform is not initialized.
    */
    Platform_Not_Initialized,

    /*
    An enumeration value provided was invalid.
    */
    Invalid_Enum_Provided,

    /*
    A value provided was invalid.
    */
    Invalid_Value_Provided,

    /*
    The requested graphics API was not available.
    */
    Graphics_Api_Unavailable,

    /*
    The requested graphics API version was not available.
    */
    Graphics_Version_Unavailable,

    /*
    The requested graphics framebuffer format was not available.
    */
    Graphics_Format_Unavailable,

    /*
    The window was created but a graphics context for it could not be created.
    */
    Window_Context_Creation_Failed,

    /*
    An error occurred in the underlying platform.

    This is a catch-all for errors that do not match a more specific error.
    */
    Platform_Error,
}

/*
An enumeration of errors that can occur when a window is destroyed.
*/
Window_Destruction_Error :: enum {
    /*
    There were no errors.
    */
    None,

    /*
    The provide window was invalid.
    */
    Invalid_Window,
}

/*
Create a new window.

### Parameters ###

* `width` - The width of the window to create.
* `height` - The height of the window to create.
* `title` - The title to give the newly created window.
* `opengl_major_version` - The major version of OpenGL to create the new window
with support for.
* `opengl_minor_version` - The minor version of OpenGL to create the new window
with support for.
* `allocator` - The allocator to use.

### Returns ###

* `window` - The newly created window on success; `nil` otherwise.
* `err` - The error that occurred on failure; `.None` otherwise.
*/
create_window :: proc(
    width: uint,
    height: uint,
    title: string,
    opengl_major_version: int = 4,
    opengl_minor_version: int = 1,
    allocator: mem.Allocator = context.allocator,
) -> (
    window: Window,
    err: Window_Creation_Error,
) {
    context.allocator = allocator

    video_mode := glfw.GetVideoMode(glfw.GetPrimaryMonitor())

    //-- Reset window hints
    glfw.DefaultWindowHints()

    //-- Window hints
    glfw.WindowHint(glfw.VISIBLE, false)
    glfw.WindowHint(glfw.RESIZABLE, false)
    glfw.WindowHint(glfw.FOCUSED, false)
    glfw.WindowHint(glfw.FOCUS_ON_SHOW, false)
    // TODO: Center on default monitor
    glfw.WindowHint(glfw.POSITION_X, (video_mode.width - cast(i32)width) / 2)
    glfw.WindowHint(glfw.POSITION_Y, (video_mode.height - cast(i32)height) / 2)

    //-- Framebuffer hints
    glfw.WindowHint(glfw.DOUBLEBUFFER, true)
    glfw.WindowHint(glfw.SAMPLES, 0)
    glfw.WindowHint(glfw.STEREO, false)

    //-- Graphics API hints
    glfw.WindowHint(glfw.CLIENT_API, glfw.OPENGL_API)
    glfw.WindowHint(glfw.CONTEXT_CREATION_API, glfw.NATIVE_CONTEXT_API)
    glfw.WindowHint(
        glfw.CONTEXT_VERSION_MAJOR,
        cast(c.int)opengl_major_version,
    )
    glfw.WindowHint(
        glfw.CONTEXT_VERSION_MINOR,
        cast(c.int)opengl_minor_version,
    )
    glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, true)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    //-- Windows-specific hints
    glfw.WindowHint(glfw.WIN32_KEYBOARD_MENU, false)
    glfw.WindowHint(glfw.WIN32_SHOWDEFAULT, false)

    //-- macOS-specific hints
    glfw.WindowHintString(glfw.COCOA_FRAME_NAME, "")
    glfw.WindowHint(glfw.COCOA_GRAPHICS_SWITCHING, false)

    //-- Wayland-specific hints
    glfw.WindowHintString(glfw.WAYLAND_APP_ID, "Odincraft")

    //-- X11-specific hints
    glfw.WindowHintString(glfw.X11_CLASS_NAME, "Odincraft")
    glfw.WindowHintString(glfw.X11_INSTANCE_NAME, "Odincraft")

    c_title := strings.clone_to_cstring(title)
    defer delete(c_title)
    window = glfw.CreateWindow(
        cast(i32)width,
        cast(i32)height,
        c_title,
        nil,
        nil,
    )
    if window == nil {
        _, glfw_err := glfw.GetError()
        switch glfw_err {
        case glfw.NOT_INITIALIZED:
            err = .Platform_Not_Initialized
        case glfw.INVALID_ENUM:
            err = .Invalid_Enum_Provided
        case glfw.INVALID_VALUE:
            err = .Invalid_Value_Provided
        case glfw.API_UNAVAILABLE:
            err = .Graphics_Api_Unavailable
        case glfw.VERSION_UNAVAILABLE:
            err = .Graphics_Version_Unavailable
        case glfw.FORMAT_UNAVAILABLE:
            err = .Graphics_Format_Unavailable
        case glfw.NO_WINDOW_CONTEXT:
            err = .Window_Context_Creation_Failed
        case glfw.PLATFORM_ERROR:
            err = .Platform_Error
        }
        return
    }
    return
}

/*
Destroy an existing window.

### Parameters ###

* `window` - The window to destroy.

### Returns ###

The error that occurred on failure; `.None` otherwise.
*/
destroy_window :: proc(window: Window) -> Window_Destruction_Error {
    if window == nil {
        return .Invalid_Window
    }
    glfw.DestroyWindow(window)
    return .None
}
