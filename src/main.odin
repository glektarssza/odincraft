package odincraft

main :: proc() {
    game := create_game()
    game_init(game)
    game_run(game)
    game_terminate(game)
}
