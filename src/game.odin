package odincraft

//-- Core Libraries
import "core:mem"

//-- Vendor Libraries
import "vendor:OpenGL"
import "vendor:glfw"

/*
The main game structure.
*/
Game :: struct {
    /*
    Whether the instance is initialized.
    */
    is_initialized: bool,

    /*
    Whether the instance is running.
    */
    is_running:     bool,

    /*
    Whether the instance should exit after the current frame.
    */
    should_exit:    bool,

    /*
    The main game window.
    */
    window:         Window,
}

/*
An enumeration of possible errors that can occur when a game is destroyed.
*/
Game_Destruction_Error :: enum {
    /*
    There were no errors.
    */
    None,

    /*
    The provide game was invalid.
    */
    Invalid_Game,

    /*
    The provided game is still initialized.
    */
    Still_Initialized,

    /*
    The provided game is still running.
    */
    Still_Running,
}

/*
An enumeration of possible errors that can occur when a game is initialized.
*/
Game_Initialize_Error :: enum {
    /*
    There were no errors.
    */
    None,

    /*
    The provide game was invalid.
    */
    Invalid_Game,

    /*
    The provided game is already initialized.
    */
    Already_Initialized,

    /*
    The underlying platform failed to initialized.
    */
    Platform_Initialization_Failed,
}

/*
An enumeration of possible errors that can occur when a game is terminated.
*/
Game_Terminate_Error :: enum {
    /*
    There were no errors.
    */
    None,

    /*
    The provide game was invalid.
    */
    Invalid_Game,

    /*
    The provided game is not initialized.
    */
    Not_Initialized,

    /*
    The provided game is still running.
    */
    Still_Running,
}

/*
An enumeration of possible errors that can occur when a game is run.
*/
Game_Run_Error :: enum {
    /*
    There were no errors.
    */
    None,

    /*
    The provide game was invalid.
    */
    Invalid_Game,

    /*
    The provided game is not initialized.
    */
    Not_Initialized,

    /*
    The provided game is already running.
    */
    Already_Running,
}

/*
Create a new game instance.

### Parameters ###

* `allocator` - The allocator to use.

### Returns ###

* `game` - The new game instance on success; `nil` on otherwise.
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

### Parameters ###

* `game` - The existing game instance to destroy.
* `allocator` - The allocator to use.

### Returns ###

The error that occurred on failure; `.None` otherwise.
*/
destroy_game :: proc(
    game: ^Game,
    allocator: mem.Allocator = context.allocator,
) -> Game_Destruction_Error {
    context.allocator = allocator
    if game == nil {
        return .Invalid_Game
    }
    if game.is_running {
        return .Still_Running
    }
    if game.is_initialized {
        return .Still_Initialized
    }
    free(game)
    return .None
}

/*
Initialize an existing game instance.

### Parameters ###

* `game` - The existing game instance to initialize.

### Returns ###

The error that occurred on failure; `.None` otherwise.
*/
game_init :: proc(game: ^Game) -> union {
        Game_Initialize_Error,
        Window_Creation_Error,
    } {
    if game == nil {
        return .Invalid_Game
    }
    if game.is_initialized {
        return .Already_Initialized
    }
    if !glfw.Init() {
        return .Platform_Initialization_Failed
    }
    game.window = create_window(1280, 720, "Odincraft") or_return
    glfw.MakeContextCurrent(game.window)
    OpenGL.load_up_to(4, 1, glfw.gl_set_proc_address)
    game.is_initialized = true
    return Game_Initialize_Error.None
}

/*
Terminate an existing game instance.

### Parameters ###

* `game` - The existing game instance to terminate.

### Returns ###

The error that occurred on failure; `.None` otherwise.
*/
game_terminate :: proc(game: ^Game) -> union {
        Game_Terminate_Error,
        Window_Destruction_Error,
    } {
    if game == nil {
        return .Invalid_Game
    }
    if !game.is_initialized {
        return .Not_Initialized
    }
    if game.is_running {
        return .Still_Running
    }
    game.is_initialized = false
    destroy_window(game.window) or_return
    game.window = nil
    return Game_Terminate_Error.None
}

/*
Run an existing game instance.

### Parameters ###

* `game` - The existing game instance to run.

### Returns ###

The error that occurred on failure; `.None` otherwise.
*/
game_run :: proc(game: ^Game) -> Game_Run_Error {
    if game == nil {
        return .Invalid_Game
    }
    if !game.is_initialized {
        return .Not_Initialized
    }
    if game.is_running {
        return .Already_Running
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
    return Game_Run_Error.None
}
