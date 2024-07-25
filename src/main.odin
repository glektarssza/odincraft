package odincraft

//-- Core Libraries
import "core:fmt"
import "core:os"

/*
A status code that can be returned to the operating system to indicate success.
*/
EXIT_SUCCESS :: 0

/*
A status code that can be returned to the operating system to indicate failure.
*/
EXIT_FAILURE :: 1

/*
The program entry point.
*/
main :: proc() {
    game, game_create_err := create_game()
    if game_create_err != .None {
        fmt.eprintfln(
            "Failed to create main game instance (%v)",
            game_create_err,
        )
        os.exit(EXIT_FAILURE)
    }
    game_init_err := game_init(game)
    if game_init_err != Game_Initialize_Error.None {
        fmt.eprintfln(
            "Failed to initialize main game instance (%v)",
            game_init_err,
        )
        destroy_game(game)
        os.exit(EXIT_FAILURE)
    }
    game_run_err := game_run(game)
    if game_run_err != Game_Run_Error.None {
        fmt.eprintfln("Failed to run main game instance (%v)", game_run_err)
        game_terminate(game)
        destroy_game(game)
        os.exit(EXIT_FAILURE)
    }
    game_terminate(game)
    destroy_game(game)
    os.exit(EXIT_SUCCESS)
}
