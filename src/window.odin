package odincraft

//-- Core Libraries
import "core:fmt"
import "core:strings"

//-- Vendor Libraries
import "vendor:glfw"

/*
A type alias for our window type.
*/
Window :: glfw.WindowHandle

/*
Create a new window.

### Parameters ###

* `width` - The width of the window to create.
* `height` - The height of the window to create.
* `title` - The title to assign to the new window.

### Returns ###

* `window` - The newly created window on success; `nil` otherwise.
* `err` - A description of the error that occurred on failure; an empty
string otherwise.
*/
create_window :: proc(
    width: uint,
    height: uint,
    title: string,
) -> (
    window: Window,
    err: string,
) {
    glfw.DefaultWindowHints()

    //-- GLFW window hints
    glfw.WindowHint(glfw.VISIBLE, false)
    glfw.WindowHint(glfw.RESIZABLE, false)
    glfw.WindowHint(glfw.FOCUSED, true)
    glfw.WindowHint(glfw.FOCUS_ON_SHOW, true)

    //-- Framebuffer hints
    glfw.WindowHint(glfw.DOUBLEBUFFER, true)
    glfw.WindowHint(glfw.SAMPLES, 0)

    //-- Graphics context hints
    glfw.WindowHint(glfw.CLIENT_API, glfw.OPENGL_API)
    glfw.WindowHint(glfw.CONTEXT_CREATION_API, glfw.NATIVE_CONTEXT_API)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR_VERSION)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, OPENGL_MINOR_VERSION)
    glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, true)
    glfw.WindowHint(glfw.CONTEXT_DEBUG, false)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    glfw.WindowHint(glfw.CONTEXT_ROBUSTNESS, glfw.NO_ROBUSTNESS)
    glfw.WindowHint(glfw.CONTEXT_RELEASE_BEHAVIOR, glfw.ANY_RELEASE_BEHAVIOR)
    glfw.WindowHint(glfw.NO_ERROR, false)

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

    //-- Create window
    window = glfw.CreateWindow(
        cast(i32)width,
        cast(i32)height,
        strings.clone_to_cstring(title),
        nil,
        nil,
    )
    if window == nil {
        err_desc, err_code := glfw.GetError()
        err = fmt.aprintf(
            "Failed to create window (%d - %s)",
            err_code,
            err_desc,
        )
        return
    }
    return
}

/*
Destroy an existing window.

### Parameters ###

* `window` - The window to destroy.
*/
destroy_window :: proc(window: Window) {
    glfw.DestroyWindow(window)
}
