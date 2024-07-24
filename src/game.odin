package odincraft

//-- Core Libraries
import "core:mem"

//-- Vendor Libraries
import "vendor:OpenGL"
import "vendor:glfw"

/*
The major version of OpenGL we are using.
*/
OPENGL_MAJOR_VERSION :: 4

/*
The minor version of OpenGL we are using.
*/
OPENGL_MINOR_VERSION :: 1

/*
The main game structure.
*/
Game :: struct {
    /*
    Whether the game is initialized.
    */
    is_initialized: bool,

    /*
    Whether the game is running.
    */
    is_running:     bool,

    /*
    Whether the game should exit after the current frame.
    */
    should_exit:    bool,

    /*
    The main game window.
    */
    window:         Window,
}

Game_Init_Error :: enum {
    None,
    Invalid_Game_Pointer,
    Already_Initialized,
    Glfw_Init_Failed,
    Window_Creation_Failed,
}

/*
Create a new game instance.

### Parameter ###

* `allocator` - The allocator to use.

### Returns ###

* `game` - The newly created game instance on success; `nil` otherwise.
* `err` - The error that occurred on failure; `.None` otherwise.
*/
create_game :: proc(
    allocator: mem.Allocator = context.allocator,
) -> (
    game: ^Game,
    err: mem.Allocator_Error,
) #optional_allocator_error {
    context.allocator = allocator
    game = new(Game) or_return
    game.is_initialized = false
    game.is_running = false
    game.should_exit = false
    game.window = nil
    return
}

/*
Destroy an existing game instance.

### Parameter ###

* `game` - The game to destroy.
* `allocator` - The allocator to use.

### Returns ###

The error that occurred on failure; `.None` otherwise.
*/
destroy_game :: proc(
    game: ^Game,
    allocator: mem.Allocator = context.allocator,
) -> mem.Allocator_Error {
    context.allocator = allocator
    if game != nil {
        destroy_window(game.window)
    }
    return free(game)
}

game_init :: proc(game: ^Game) -> Game_Init_Error {
    if game == nil {
        return .Invalid_Game_Pointer
    }
    if game.is_initialized {
        return .Already_Initialized
    }
    if !glfw.Init() {
        return .Glfw_Init_Failed
    }
    win, _ := create_window(1280, 720, "Odincraft")
    if win == nil {
        return .Window_Creation_Failed
    }
    game.window = win
    glfw.MakeContextCurrent(game.window)
    OpenGL.load_up_to(
        OPENGL_MAJOR_VERSION,
        OPENGL_MINOR_VERSION,
        glfw.gl_set_proc_address,
    )
    game.is_initialized = true
    return .None
}

game_terminate :: proc(game: ^Game) {
    if game == nil {
        return
    }
    game.is_initialized = false
    if game.window != nil {
        destroy_window(game.window)
        game.window = nil
    }
    glfw.Terminate()
}

game_run :: proc(game: ^Game) {
    if game == nil {
        return
    }
    if game.window == nil {
        return
    }
    if !game.is_initialized {
        return
    }
    if game.is_running {
        return
    }
    game.is_running = true
    glfw.ShowWindow(game.window)
    for !game.should_exit {
        glfw.PollEvents()
        if glfw.GetKey(game.window, glfw.KEY_ESCAPE) == glfw.PRESS {
            glfw.SetWindowShouldClose(game.window, true)
        }
        if glfw.WindowShouldClose(game.window) {
            game.should_exit = true
            glfw.SetWindowShouldClose(game.window, false)
        }
        glfw.MakeContextCurrent(game.window)
        OpenGL.ClearColor(100.0 / 255.0, 149.0 / 255.0, 237.0 / 255.0, 1.0)
        OpenGL.Clear(OpenGL.COLOR_BUFFER_BIT)
        glfw.SwapBuffers(game.window)
    }
    glfw.HideWindow(game.window)
    game.is_running = false
}
